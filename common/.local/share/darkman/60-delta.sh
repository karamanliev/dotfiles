#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"
GIT_CONFIG_DIR="$HOME/.config/git"

source "$CONFIG_FILE"

case "$MODE" in
light)
  CURRENT_THEME="$LIGHT_THEME"
  DELTA_FILE="delta-light.conf"
  ;;
dark)
  CURRENT_THEME="$DARK_THEME"
  DELTA_FILE="delta-dark.conf"
  ;;
*)
  exit 0
  ;;
esac

[[ -r "$GIT_CONFIG_DIR/$DELTA_FILE" ]] || exit 0
sed "s|^  syntax-theme = .*|  syntax-theme = $CURRENT_THEME|" \
  "$GIT_CONFIG_DIR/$DELTA_FILE" >"$GIT_CONFIG_DIR/delta.conf"
