#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"

source "$CONFIG_FILE"

case "$MODE" in
light) CURRENT_THEME="$LIGHT_THEME" ;;
dark) CURRENT_THEME="$DARK_THEME" ;;
*) exit 0 ;;
esac

command -v nvim >/dev/null 2>&1 || exit 0

for sock in /tmp/nvim*; do
  [[ -S "$sock" ]] || continue
  nvim --server "$sock" --remote-send "<cmd>silent! colorscheme ${CURRENT_THEME}<CR>" >/dev/null 2>&1 || true
done
