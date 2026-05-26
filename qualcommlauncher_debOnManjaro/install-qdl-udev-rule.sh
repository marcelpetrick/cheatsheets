#!/usr/bin/env bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/99-qualcomm-qdl.rules"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo $0" >&2
  exit 1
fi

cat > "$RULE_FILE" <<'RULE'
# Qualcomm emergency download / QDL mode used by Rubik Pi flashing.
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", ATTR{idProduct}=="9008", MODE="0666", TAG+="uaccess"
RULE

udevadm control --reload-rules
udevadm trigger --subsystem-match=usb --attr-match=idVendor=05c6 --attr-match=idProduct=9008 || true

echo "Installed $RULE_FILE"
echo "Unplug and reconnect the board, then run the launcher as your normal user."
