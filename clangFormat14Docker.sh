#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: clangFormat14Docker.sh [--check]

Runs the CI clang-format version locally via Docker.

What it does:
  - Starts a disposable gcc:14-bookworm Docker container.
  - Installs clang-format-14 inside that container.
  - Formats all tracked *.cpp, *.h, and *.hpp files.
  - Excludes easyANALYZER-XX.XX/04_SystemTests/, matching the CI job.
  - Uses clang-format's file style lookup, so files under
    easyANALYZER-XX.XX/03_SourceCode/Source use that directory's .clang-format.
  - Mounts the git metadata correctly when easyAnalyzer is used as a submodule.

CI command mirrored:
  clang-format --version
  git ls-files "*.cpp" "*.h" "*.hpp" | Where-Object { $_ -notmatch "easyANALYZER-XX.XX\\04_SystemTests\\" } | ForEach-Object { clang-format -i $_ }
  git status
  git diff --exit-code

Note:
  Git path output is normalized to forward slashes in this Bash script, so the
  04_SystemTests exclusion is implemented with forward slashes.

Prerequisites:
  - bash
  - git
  - python3
  - docker

Platform:
  This script is intended for Linux or WSL/Git-Bash style environments where
  Docker accepts Unix-style bind mount paths. It is not a native PowerShell
  script. On Windows, run it from WSL or Git Bash with Docker available.

Examples:
  easyANALYZER-XX.XX/05_Tools/clangFormat14Docker.sh
  easyANALYZER-XX.XX/05_Tools/clangFormat14Docker.sh --check

Options:
  --check   Format files, then fail if git diff detects changes.
  -h, --help
            Show this help.
EOF
}

check_mode=0
for arg in "$@"; do
    case "$arg" in
        --check)
            check_mode=1
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

if ! command -v docker >/dev/null 2>&1; then
    echo "docker is required but was not found in PATH." >&2
    exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
git_common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"

# Mount a directory that contains both the worktree and the real git metadata.
# This also works when easyAnalyzer is checked out as a git submodule.
mount_root="$(python3 - "$repo_root" "$git_common_dir" <<'PY'
import os
import sys

print(os.path.commonpath([sys.argv[1], sys.argv[2]]))
PY
)"

docker run --rm \
    -v "${mount_root}:${mount_root}" \
    -w "${repo_root}" \
    gcc:14-bookworm \
    bash -lc '
        set -euo pipefail
        git config --global --add safe.directory "$PWD"
        apt-get update >/dev/null
        apt-get install -y clang-format-14 >/dev/null
        clang-format-14 --version
        git ls-files -z "*.cpp" "*.h" "*.hpp" |
            grep -z -v "easyANALYZER-XX.XX/04_SystemTests/" |
            xargs -0 -r clang-format-14 --style=file -i
    '

if [[ "$check_mode" -eq 1 ]]; then
    git status --short
    git diff --exit-code || {
        echo "Code format issues found. Please run ${0} locally and commit the result." >&2
        exit 1
    }
fi
