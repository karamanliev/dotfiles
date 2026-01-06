#!/bin/bash

WP_FOLDER="$HOME/Pictures/Wallpapers/Vertical/"
WP_INDEX_FILE="$HOME/.cache/rwpspread/current_wallpaper_index"

if [ ! -f "$WP_INDEX_FILE" ]; then
  echo 0 >"$WP_INDEX_FILE"
fi

load_wallpapers() {
  readarray -t WALLPAPERS_ARR < <(find "$WP_FOLDER" -type f)
  WALLPAPERS_COUNT=${#WALLPAPERS_ARR[@]}
}

get_current_wallpaper() {
  CURRENT_INDEX=$(cat "$WP_INDEX_FILE")
  CURRENT_WALLPAPER="${WALLPAPERS_ARR[$CURRENT_INDEX]}"
}

get_wallpaper_index_by_path() {
  local file_path="$1"
  # local file_name=$(basename "$file_path")

  for i in "${!WALLPAPERS_ARR[@]}"; do
    if [ "${WALLPAPERS_ARR[$i]}" = "$file_path" ]; then
      echo "$i"
      return 0
    fi
  done
  echo "-1"
  return 1
}

if [ "$1" = "daemon" ]; then
  pidof wpaperd && killall -9 -q wpaperd
  pidof rwpspread && killall -9 -q rwpspread

  load_wallpapers
  get_current_wallpaper

  rwpspread -b wpaperd -di "$CURRENT_WALLPAPER" &
  disown
else
  load_wallpapers

  CURRENT_INDEX=$(cat "$WP_INDEX_FILE")

  if [ "$1" = "next" ]; then
    CURRENT_INDEX=$(((CURRENT_INDEX + 1) % WALLPAPERS_COUNT))
  elif [ "$1" = "prev" ]; then
    CURRENT_INDEX=$(((CURRENT_INDEX - 1 + WALLPAPERS_COUNT) % WALLPAPERS_COUNT))
  elif [ "$1" = "random" ]; then
    RANDOM_INDEX=$((RANDOM % WALLPAPERS_COUNT))
    # Ensure the random index is different from the current one
    while [ "$RANDOM_INDEX" -eq "$CURRENT_INDEX" ]; do
      RANDOM_INDEX=$((RANDOM % WALLPAPERS_COUNT))
    done
    CURRENT_INDEX=$RANDOM_INDEX
  elif [ "$1" = "current" ]; then
    CURRENT_INDEX=$(cat "$WP_INDEX_FILE")
  # If the argument is path to a file
  elif [ -f "$1" ]; then
    NEW_INDEX=$(get_wallpaper_index_by_path "$1")
    if [ "$NEW_INDEX" -ge 0 ]; then
      CURRENT_INDEX="$NEW_INDEX"
    else
      echo "Error: Wallpaper '$1' not found in '$WP_FOLDER'."
      exit 1
    fi
  else
    echo "Error: Invalid argument or file does not exist."
    exit 1
  fi

  echo "$CURRENT_INDEX" >"$WP_INDEX_FILE"

  CURRENT_WALLPAPER="${WALLPAPERS_ARR[$CURRENT_INDEX]}"
  rwpspread -b wpaperd -i "$CURRENT_WALLPAPER"
fi
