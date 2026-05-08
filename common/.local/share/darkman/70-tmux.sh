#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"
TMUX_THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/themes"
TMUX_CURRENT_THEME_FILE="$TMUX_THEME_DIR/current_theme.conf"

source "$CONFIG_FILE"

case "$MODE" in
light) CURRENT_THEME="$LIGHT_THEME" ;;
dark) CURRENT_THEME="$DARK_THEME" ;;
*) exit 0 ;;
esac

THEME_FILE="$TMUX_THEME_DIR/$CURRENT_THEME.conf"

[[ -r "$THEME_FILE" ]] || exit 0

mkdir -p "$TMUX_THEME_DIR"
ln -sfn "$THEME_FILE" "$TMUX_CURRENT_THEME_FILE"

if command -v tmux >/dev/null 2>&1; then
  tmux source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/theme.conf" >/dev/null 2>&1 || true
fi
