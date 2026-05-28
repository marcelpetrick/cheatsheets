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

# Detect GPU order dynamically from DRM cards
declare -A GPU_NAMES

for card in /sys/class/drm/card*/device/vendor; do
  idx=$(basename "$(dirname "$(dirname "$card")")" | sed 's/card//')
  vendor=$(cat "$card")

  case "$vendor" in
    0x10de)
      GPU_NAMES[$idx]='"NVIDIA RTX A2000 8GB Laptop GPU"'
      ;;
    0x8086)
      GPU_NAMES[$idx]='"Intel Iris Xe Graphics"'
      ;;
    *)
      GPU_NAMES[$idx]='"Unknown GPU"'
      ;;
  esac
done

# Apply names according to actual kernel enumeration
for idx in "${!GPU_NAMES[@]}"; do
  set_or_add "custom_gpu_name${idx}" "${GPU_NAMES[$idx]}"
done

# Clear unused custom names
for idx in 2 3 4 5; do
  set_or_add "custom_gpu_name${idx}" '""'
done

# Ensure GPU boxes are shown
set_or_add "shown_boxes" '"cpu mem net proc gpu0 gpu1"'

echo
echo "Detected GPU mapping:"
for idx in "${!GPU_NAMES[@]}"; do
  echo "  gpu${idx} -> ${GPU_NAMES[$idx]}"
done

echo
echo "Config updated:"
echo "  $CONF"

echo
echo "Now restart btop:"
echo "  btop"

echo
echo "Tip:"
echo "  Press 5/6 or p inside btop if GPU panels are hidden by the current preset."
