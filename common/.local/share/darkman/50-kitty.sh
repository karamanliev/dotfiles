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
kitten themes --dump-theme "$CURRENT_THEME" >"$THEME_FILE"

if pgrep -x kitty >/dev/null 2>&1; then
  # Wait until kitty's socket appears (kitty is fully initialized)
  until ls /tmp/kitty-*.sock &>/dev/null; do sleep 0.1; done
  for sock in /tmp/kitty-*.sock; do
    kitten @ --to "unix:$sock" set-colors --all --configured "$THEME_FILE" &>/dev/null || true
  done
fi
