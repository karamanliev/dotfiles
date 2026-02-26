#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"

source "$CONFIG_FILE"

case "$MODE" in
light)
  CURRENT_GTK_THEME="$LIGHT_GTK_THEME"
  CURRENT_GTK_ICON_THEME="$LIGHT_GTK_ICON_THEME"
  CURRENT_GTK_COLOR_SCHEME="prefer-light"
  ;;
dark)
  CURRENT_GTK_THEME="$DARK_GTK_THEME"
  CURRENT_GTK_ICON_THEME="$DARK_GTK_ICON_THEME"
  CURRENT_GTK_COLOR_SCHEME="prefer-dark"
  ;;
*)
  exit 0
  ;;
esac

command -v gsettings >/dev/null 2>&1 || exit 0

gsettings set org.gnome.desktop.interface color-scheme "$CURRENT_GTK_COLOR_SCHEME" >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface gtk-theme "$CURRENT_GTK_THEME" >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface icon-theme "$CURRENT_GTK_ICON_THEME" >/dev/null 2>&1 || true
