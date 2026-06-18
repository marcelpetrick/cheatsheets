#!/usr/bin/env bash
# gitlab_yaml_check.sh
# Validates a GitLab CI YAML file locally before pushing, catching issues that
# cause "Unable to run pipeline" failures at the GitLab validation stage.
#
# Usage:
#   ./gitlab_yaml_check.sh [path/to/ci-file.yml]
#   File defaults to .gitlab/datamodul-ci.yml
#
# Optional env vars (enable remote lint via the GitLab CI API):
#   GITLAB_TOKEN       personal access token with at least api scope
#   GITLAB_PROJECT_ID  numeric project id  (project Settings -> General)
#   GITLAB_URL         GitLab host, defaults to https://gitlab.com

set -euo pipefail

FILE="${1:-.gitlab/datamodul-ci.yml}"
ERRORS=0
WARNINGS=0

err()     { echo "  [ERR]  $*"; ERRORS=$((ERRORS + 1)); }
warn()    { echo "  [WARN] $*"; WARNINGS=$((WARNINGS + 1)); }
ok()      { echo "  [OK]   $*"; }
section() { printf '\n── %s\n' "$*"; }

[ -f "$FILE" ] || { echo "File not found: $FILE"; exit 1; }
command -v python3 &>/dev/null || { echo "python3 is required (pip install pyyaml)"; exit 1; }

echo "Validating: $FILE"

# ── 1. YAML syntax ────────────────────────────────────────────────────────────
section "1. YAML syntax (PyYAML)"

SYNTAX_OUT=$(python3 - "$FILE" 2>&1 <<'PYTHON' || true
import sys, yaml
try:
    yaml.safe_load(open(sys.argv[1]))
    print("OK")
except ImportError:
    print("SKIP:pyyaml not installed -- run: pip install pyyaml")
    sys.exit(0)
except yaml.YAMLError as e:
    print(f"FAIL:{e}")
    sys.exit(1)
PYTHON
)

case "$SYNTAX_OUT" in
    OK)      ok "Parses without errors" ;;
    SKIP:*)  warn "${SYNTAX_OUT#SKIP:}" ;;
    FAIL:*)  err "${SYNTAX_OUT#FAIL:}" ;;
    *)       err "Unexpected output: $SYNTAX_OUT" ;;
esac

# ── 2. No tab characters ──────────────────────────────────────────────────────
section "2. No tab characters"

TABS=$(grep -Pn '\t' "$FILE" | cut -d: -f1 | paste -sd ',' - 2>/dev/null || true)
if [ -n "$TABS" ]; then
    err "Tab character(s) on line(s): $TABS  (YAML requires spaces, not tabs)"
else
    ok "No tabs found"
fi

# ── 3. Multi-line plain-scalar continuations in script blocks ─────────────────
# Root cause of "script config should be a string or a nested array of strings"
#
# GitLab uses Ruby's Psych YAML parser, which diverges from the YAML spec:
# instead of folding indented continuation lines into the preceding plain scalar,
# Psych treats them as nested array elements -- making a valid string look like
# an illegal nested structure to the GitLab validator.
#
# Typical offender:
#   before_script:
#     - apt-get install -y --no-install-recommends   # <- scalar start
#         build-essential                             # <- Psych: nested item!
#         libfoo-dev
#
# Fix: collapse to one line, or use a block scalar (|).

section "3. Multi-line plain-scalar continuations in script/before_script/after_script"

CONT_OUT=$(python3 - "$FILE" 2>&1 <<'PYTHON' || true
import sys, re

SCRIPT_KEYS = {'script', 'before_script', 'after_script'}

with open(sys.argv[1]) as fh:
    lines = fh.readlines()

issues = []
in_script = False
block_indent = 0

for i, raw in enumerate(lines):
    line = raw.rstrip('\n')

    # Detect any YAML key (with or without inline value)
    key_m = re.match(r'^(\s*)(\w+)\s*:', line)
    if key_m:
        indent = len(key_m.group(1))
        key = key_m.group(2)
        if key in SCRIPT_KEYS:
            # Entering a script-type block; skip further processing of this line
            in_script = True
            block_indent = indent
            continue
        if in_script and indent <= block_indent:
            # A new key at the same or outer level ends the script block
            in_script = False
            continue

    if not in_script:
        continue

    # A sequence item line
    seq_m = re.match(r'^(\s*)(- )(.+)', line)
    if not seq_m:
        continue

    item_col = len(seq_m.group(1))
    item_value = seq_m.group(3).strip()

    # Block scalar indicators (| > |- |+ >- >+ |2 etc.): the indented lines
    # below are the literal/folded scalar content — perfectly valid, skip.
    if re.match(r'^[|>][|>+\-0-9]*\s*$', item_value):
        continue
    # Already explicitly quoted — parser has no ambiguity, skip.
    if item_value.startswith("'") or item_value.startswith('"'):
        continue
    # Multi-line shell constructs: a line ending with { (PowerShell if/foreach)
    # or \ (POSIX shell line continuation) tells the reader the command
    # intentionally spans lines — Psych handles these correctly in practice.
    if item_value.endswith('{') or item_value.endswith('\\'):
        continue

    # Find the next non-empty line
    j = i + 1
    while j < len(lines) and lines[j].strip() == '':
        j += 1
    if j >= len(lines):
        continue

    next_line = lines[j].rstrip('\n')
    next_m = re.match(r'^(\s*)\S', next_line)
    if not next_m:
        continue

    next_col = len(next_m.group(1))

    # Continuation: indented further than '-', not a new item or comment
    if (next_col > item_col
            and not re.match(r'^\s*-', next_line)
            and not re.match(r'^\s*#', next_line)):
        issues.append(
            f"ISSUE:line {i+1}: multi-line plain-scalar continuation\n"
            f"  Psych misreads line {j+1} as a nested array element.\n"
            f"  Fix: collapse to one line or use a block scalar (|).\n"
            f"  Item:   {line.strip()}\n"
            f"  Cont.:  {next_line.strip()}"
        )

if issues:
    for iss in issues:
        print(iss)
    sys.exit(1)
else:
    print("OK")
PYTHON
)

if [[ "$CONT_OUT" == OK ]]; then
    ok "No multi-line plain-scalar continuations found"
else
    while IFS= read -r line; do
        case "$line" in
            ISSUE:*) err "${line#ISSUE:}" ;;
            *)       echo "         $line" ;;
        esac
    done <<< "$CONT_OUT"
fi

# ── 4. Shell operators + embedded double-quotes in plain scalars ───────────────
# A YAML plain scalar (no surrounding quotes) that contains || or && together
# with embedded " characters is accepted by the spec but rejected or warned
# about by strict linters (including the GitLab Web IDE and some editors).
#
# Fix: wrap the entire value in single quotes, or rewrite as if/then/fi.

section "4. Shell operators with embedded double-quotes in plain scalars"

SHELL_OUT=$(python3 - "$FILE" 2>&1 <<'PYTHON' || true
import sys, re

with open(sys.argv[1]) as fh:
    lines = fh.readlines()

issues = []
for i, raw in enumerate(lines, 1):
    stripped = raw.strip()
    m = re.match(r'^- (.+)', stripped)
    if not m:
        continue
    value = m.group(1)
    # Skip values that are already explicitly quoted
    if value.startswith("'") or value.startswith('"'):
        continue
    if ('||' in value or '&&' in value) and '"' in value:
        issues.append(f"WARN:line {i}: {value[:100]}")

if issues:
    for iss in issues:
        print(iss)
else:
    print("OK")
PYTHON
)

if [[ "$SHELL_OUT" == OK ]]; then
    ok "No risky plain scalars found"
else
    while IFS= read -r line; do
        case "$line" in
            WARN:*) warn "${line#WARN:} — wrap in single quotes or use if/then/fi" ;;
            *)      echo "         $line" ;;
        esac
    done <<< "$SHELL_OUT"
fi

# ── 5. Colon-space (": ") in plain scalar script items ───────────────────────
# A colon followed by a space inside an unquoted YAML plain scalar is a YAML
# mapping key separator. Psych parses `echo "ERROR: msg"` as a mapping with
# key `echo "ERROR` and value `msg"`, making the item neither a string nor an
# array — hence "script config should be a string or a nested array of strings".
#
# Fix: wrap the entire command in single quotes so YAML sees a quoted scalar:
#   - 'if [ ... ]; then echo "ERROR: msg"; exit 1; fi'

section "5. Colon-space in plain scalar script items"

COLON_OUT=$(python3 - "$FILE" 2>&1 <<'PYTHON' || true
import sys, re

SCRIPT_KEYS = {'script', 'before_script', 'after_script'}

with open(sys.argv[1]) as fh:
    lines = fh.readlines()

issues = []
in_script = False
block_indent = 0

for i, raw in enumerate(lines, 1):
    line = raw.rstrip('\n')

    key_m = re.match(r'^(\s*)(\w+)\s*:', line)
    if key_m:
        indent = len(key_m.group(1))
        key = key_m.group(2)
        if key in SCRIPT_KEYS:
            in_script = True
            block_indent = indent
            continue
        if in_script and indent <= block_indent:
            in_script = False
            continue

    if not in_script:
        continue

    seq_m = re.match(r'^(\s*)(- )(.+)', line)
    if not seq_m:
        continue

    value = seq_m.group(3).strip()

    # Skip block scalars and explicitly quoted values — they are unambiguous
    if re.match(r'^[|>][|>+\-0-9]*\s*$', value):
        continue
    if value.startswith("'") or value.startswith('"'):
        continue

    # A plain scalar containing ": " (colon + space) will be misread by Psych
    # as a YAML mapping key/value pair instead of a string.
    if ': ' in value:
        issues.append(f"ISSUE:line {i}: plain scalar contains ': ' (colon-space)\n"
                      f"  Psych interprets this as a YAML mapping separator.\n"
                      f"  Fix: wrap the command in single quotes.\n"
                      f"  Value: {value[:100]}")

if issues:
    for iss in issues:
        print(iss)
    sys.exit(1)
else:
    print("OK")
PYTHON
)

if [[ "$COLON_OUT" == OK ]]; then
    ok "No colon-space in plain scalar script items"
else
    while IFS= read -r line; do
        case "$line" in
            ISSUE:*) err "${line#ISSUE:}" ;;
            *)       echo "         $line" ;;
        esac
    done <<< "$COLON_OUT"
fi

# ── 6. GitLab CI lint API (optional) ─────────────────────────────────────────
section "6. GitLab CI lint API"

if [ -z "${GITLAB_TOKEN:-}" ] || [ -z "${GITLAB_PROJECT_ID:-}" ]; then
    warn "Skipped — set GITLAB_TOKEN and GITLAB_PROJECT_ID to enable"
else
    GITLAB_HOST="${GITLAB_URL:-https://gitlab.com}"
    PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({'content': open(sys.argv[1]).read()}))
" "$FILE")

    HTTP_STATUS=$(curl -s -o /tmp/gl_lint_response.json -w "%{http_code}" \
        --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data "$PAYLOAD" \
        "$GITLAB_HOST/api/v4/projects/$GITLAB_PROJECT_ID/ci/lint" 2>/dev/null || echo "000")

    if [ "$HTTP_STATUS" != "200" ]; then
        warn "GitLab API returned HTTP $HTTP_STATUS (network or auth issue)"
    else
        python3 - <<'PYTHON'
import json, sys
try:
    with open('/tmp/gl_lint_response.json') as f:
        d = json.load(f)
    if d.get('valid'):
        print("OK")
    else:
        for e in d.get('errors', ['(no detail)']):
            print(f"FAIL:{e}")
        sys.exit(1)
except Exception as e:
    print(f"WARN:Could not parse API response: {e}")
PYTHON
        API_OUT=$(cat /tmp/gl_lint_response.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
if d.get('valid'):
    print('OK')
else:
    for e in d.get('errors', ['(no detail)']):
        print(f'FAIL:{e}')
" 2>/dev/null || echo "WARN:parse error")
        while IFS= read -r line; do
            case "$line" in
                OK)     ok "GitLab API: valid" ;;
                FAIL:*) err "GitLab API: ${line#FAIL:}"; ;;
                WARN:*) warn "GitLab API: ${line#WARN:}" ;;
            esac
        done <<< "$API_OUT"
    fi
fi

# ── summary ───────────────────────────────────────────────────────────────────
printf '\n%s\n' "────────────────────────────────────────────────────────"
if [ "$ERRORS" -gt 0 ]; then
    printf 'FAILED  %d error(s), %d warning(s) — fix before pushing\n' "$ERRORS" "$WARNINGS"
    exit 1
else
    printf 'PASSED  %d error(s), %d warning(s)\n' "$ERRORS" "$WARNINGS"
fi
