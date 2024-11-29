#!/bin/bash

WP_FOLDER="$HOME/Pictures/Wallpapers/Ultrawide/"
WP_INDEX_FILE="$HOME/Pictures/Wallpapers/current_wallpaper_index"

if [ ! -f "$WP_INDEX_FILE" ]; then
  echo 0 >"$WP_INDEX_FILE"
fi

load_wallpapers() {
  readarray -t WALLPAPERS_ARR < <(ls -1 "$WP_FOLDER")
  WALLPAPERS_COUNT=${#WALLPAPERS_ARR[@]}
}

get_current_wallpaper() {
  CURRENT_INDEX=$(cat "$WP_INDEX_FILE")
  CURRENT_WALLPAPER="${WALLPAPERS_ARR[$CURRENT_INDEX]}"
}

if [ "$1" = "daemon" ]; then
  pidof hyprpaper && killall -9 -q hyprpaper
  pidof rwpspread && killall -9 -q rwpspread

  load_wallpapers
  get_current_wallpaper

  rwpspread -b hyprpaper -di "$WP_FOLDER/$CURRENT_WALLPAPER"
else
  load_wallpapers

  CURRENT_INDEX=$(cat "$WP_INDEX_FILE")

  if [ "$1" = "next" ]; then
    CURRENT_INDEX=$(((CURRENT_INDEX + 1) % WALLPAPERS_COUNT))
  elif [ "$1" = "prev" ]; then
    CURRENT_INDEX=$(((CURRENT_INDEX - 1 + WALLPAPERS_COUNT) % WALLPAPERS_COUNT))
  fi

  echo "$CURRENT_INDEX" >"$WP_INDEX_FILE"

  CURRENT_WALLPAPER="${WALLPAPERS_ARR[$CURRENT_INDEX]}"
  rwpspread -b hyprpaper -i "$WP_FOLDER/$CURRENT_WALLPAPER"
fi
