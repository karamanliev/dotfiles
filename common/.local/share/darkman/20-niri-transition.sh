#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"

source "$CONFIG_FILE"

case "$MODE" in
light | dark) ;;
*) exit 0 ;;
esac

if [[ "${ENABLE_NIRI_TRANSITION}" == "1" ]] && command -v niri >/dev/null 2>&1; then
  niri msg action do-screen-transition --delay-ms "${NIRI_TRANSITION_DELAY_MS}" >/dev/null 2>&1 || true
fi
