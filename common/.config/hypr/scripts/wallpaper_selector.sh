#!/bin/sh

WP_DIR=${1:-$HOME/Pictures/Wallpapers/Favourite/}
WP_SCRIPT=${2:-$HOME/.config/hypr/scripts/wallpaper.sh}

rofi -no-config -theme fullscreen-preview.rasi \
  -show filebrowser -filebrowser-command "$WP_SCRIPT" \
  -filebrowser-directory "$WP_DIR" \
  -filebrowser-sorting-method name \
  -selected-row 1 >/dev/null
