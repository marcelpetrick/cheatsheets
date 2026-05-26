#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$HERE/deb-extracted/opt/qcom/qualcommlauncher/bin"
APP="$APP_DIR/qualcommlauncher"
COMPAT_LIB_DIR="$HERE/compat-libs/libxml2-legacy/usr/lib"

if [[ ! -x "$APP" ]]; then
  echo "Qualcomm Launcher binary not found at: $APP" >&2
  echo "Run the extraction step again from this directory." >&2
  exit 1
fi

if [[ -d "$COMPAT_LIB_DIR" ]]; then
  export LD_LIBRARY_PATH="$COMPAT_LIB_DIR:$APP_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
else
  export LD_LIBRARY_PATH="$APP_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

cd "$APP_DIR"
exec "$APP" --no-sandbox "$@"
