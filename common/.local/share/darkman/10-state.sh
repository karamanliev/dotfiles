#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/current_theme"

source "$CONFIG_FILE"

case "$MODE" in
light) CURRENT_THEME="$LIGHT_THEME" ;;
dark) CURRENT_THEME="$DARK_THEME" ;;
*) exit 0 ;;
esac

mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n' "$CURRENT_THEME" >"$STATE_FILE"

mkdir -p "$HOME/.config/vivid"
printf '%s\n' "$CURRENT_THEME" >"$HOME/.config/vivid/current_theme"
