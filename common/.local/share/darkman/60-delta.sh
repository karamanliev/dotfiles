#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"
GIT_CONFIG_DIR="$HOME/.config/git"

source "$CONFIG_FILE"

case "$MODE" in
light) CURRENT_THEME="$LIGHT_THEME" ;;
dark)  CURRENT_THEME="$DARK_THEME" ;;
*)     exit 0 ;;
esac

DELTA_FILE="$GIT_CONFIG_DIR/$CURRENT_THEME.conf"
[[ -r "$DELTA_FILE" ]] || exit 0
cp "$DELTA_FILE" "$GIT_CONFIG_DIR/delta.conf"

cat "$GIT_CONFIG_DIR/delta.conf"
