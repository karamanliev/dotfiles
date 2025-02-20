#!/usr/bin/env bash

VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [ "$SCROLL_DELTA" -lt 0 ]; then
  aerospace volume down
elif [ "$SCROLL_DELTA" -gt 0 ]; then
  aerospace volume up
fi

if [ "$MUTED" != "false" ]; then
  ICON="󰖁"
  VOLUME=0
else
  case ${VOLUME} in
  100) ICON="" ;;
  [5-9]*) ICON="" ;;
  [0-9]*) ICON="" ;;
  *) ICON="" ;;
  esac
fi

sketchybar -m \
  --set "$NAME" icon=$ICON \
  --set "$NAME" label="$VOLUME%"
