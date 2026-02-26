#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"
BTOP_THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/btop/themes"
BTOP_CURRENT_THEME_FILE="$BTOP_THEMES_DIR/current.theme"

source "$CONFIG_FILE"

case "$MODE" in
light) CURRENT_THEME="$LIGHT_THEME" ;;
dark) CURRENT_THEME="$DARK_THEME" ;;
*) exit 0 ;;
esac

THEME_FILE="$BTOP_THEMES_DIR/${CURRENT_THEME}.theme"
[[ -r "$THEME_FILE" ]] || exit 0

cat "$THEME_FILE" >"$BTOP_CURRENT_THEME_FILE"
