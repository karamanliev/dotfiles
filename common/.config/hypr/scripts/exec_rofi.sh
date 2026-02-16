#!/bin/bash

LAST_MODE_FILE="/tmp/last_rofi_mode"

last_mode=$(cat "$LAST_MODE_FILE")

echo "$1" >"$LAST_MODE_FILE"

if hyprctl layers | grep -qi "rofi"; then
  if [ "$1" = "$last_mode" ]; then
    pkill -x rofi
  else
    pkill -x rofi
    wait
    rofi -show "$1"
  fi
else
  if [ "$1" = "calc" ]; then
    rofi -show calc -no-show-match -no-sort -kb-accept-custom "Return" -kb-accept-entry "Ctrl+Return" -calc-command "echo '{result}' | wl-copy"
  else

    rofi -show "$1"
  fi
fi
