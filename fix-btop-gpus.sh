#!/usr/bin/env bash
set -euo pipefail

CONF="$HOME/.config/btop/btop.conf"

mkdir -p "$HOME/.config/btop"

# Generate default config if missing
if [[ ! -f "$CONF" ]]; then
  btop --help >/dev/null 2>&1 || true
  timeout 2 btop >/dev/null 2>&1 || true
fi

# Backup existing config
if [[ -f "$CONF" ]]; then
  cp "$CONF" "$CONF.bak.$(date +%Y%m%d-%H%M%S)"
else
  touch "$CONF"
fi

set_or_add() {
  local key="$1"
  local value="$2"

  if grep -qE "^${key} =" "$CONF"; then
    sed -i "s|^${key} =.*|${key} = ${value}|" "$CONF"
  else
    printf '\n%s = %s\n' "$key" "$value" >> "$CONF"
  fi
}

set_or_add "custom_gpu_name0" '"Intel Iris Xe Graphics"'
set_or_add "custom_gpu_name1" '"NVIDIA RTX A2000 8GB Laptop GPU"'

# Show GPU boxes if your btop build supports them
set_or_add "shown_boxes" '"cpu mem net proc gpu0 gpu1"'

echo "Done. Backup saved next to:"
echo "$CONF"
echo
echo "Now start:"
echo "  btop"
echo
echo "Inside btop, press 5/6 or p if the GPU boxes are hidden by the current preset."
