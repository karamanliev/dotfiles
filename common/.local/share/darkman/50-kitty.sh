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

command -v kitten >/dev/null 2>&1 || exit 0

THEME_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/current-theme.conf"
kitten themes --cache-age=-1 --dump-theme "$CURRENT_THEME" >"$THEME_FILE"

shopt -s nullglob
for sock in /tmp/kitty-*.sock; do
  [[ -S "$sock" ]] || continue
  kitten @ --to "unix:$sock" set-colors --all --configured "$THEME_FILE" &>/dev/null || true
done
