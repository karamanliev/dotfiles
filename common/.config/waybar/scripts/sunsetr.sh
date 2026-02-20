#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source machine-specific brightness backend (arch: ddcutil, thinkpad: brightnessctl)
source "$SCRIPT_DIR/brightness.sh"

set_gtk_theme() {
  local period="$1"
  case "$period" in
    day|sunset)
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
      ;;
    night|sunrise)
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      ;;
  esac
}

get_status() {
  BRIGHTNESS="$(get_brightness)"
  SUNSETR_STATUS=$(sunsetr status --json 2>/dev/null)

  if [ $? -eq 0 ]; then
    PERIOD=$(echo "$SUNSETR_STATUS" | jq -r '.period // "day"')
    PRESET=$(echo "$SUNSETR_STATUS" | jq -r '.active_preset // "default"')
    TEMP=$(echo "$SUNSETR_STATUS" | jq -r '.current_temp // "0"')
    GAMMA=$(echo "$SUNSETR_STATUS" | jq -r '.current_gamma // "0"')
    NEXT_PERIOD=$(echo "$SUNSETR_STATUS" | jq -r '.next_period // null')

    NEXT_PERIOD_INFO=""
    if [ "$NEXT_PERIOD" != "null" ] && [ -n "$NEXT_PERIOD" ]; then
      FORMATTED_TIME=$(date -d "$NEXT_PERIOD" '+%H:%M:%S' 2>/dev/null)
      if [ $? -eq 0 ]; then
        CURRENT_EPOCH=$(date +%s)
        NEXT_EPOCH=$(date -d "$NEXT_PERIOD" +%s 2>/dev/null)
        if [ $? -eq 0 ]; then
          SECONDS_LEFT=$((NEXT_EPOCH - CURRENT_EPOCH))
          if [ $SECONDS_LEFT -ge 0 ]; then
            HOURS=$((SECONDS_LEFT / 3600))
            MINUTES=$(((SECONDS_LEFT % 3600) / 60))
            NEXT_PERIOD_INFO="\\nNext transition: $FORMATTED_TIME (in ${HOURS}h${MINUTES}m)"
          else
            NEXT_PERIOD_INFO="\\nNext transition: $FORMATTED_TIME"
          fi
        else
          NEXT_PERIOD_INFO="\\nNext transition: $FORMATTED_TIME"
        fi
      fi
    fi

    echo "{\"text\": \"$BRIGHTNESS\", \"alt\": \"$PERIOD\", \"tooltip\": \"Preset: $PRESET\\nPeriod: $PERIOD\\nTemp: ${TEMP}K @ ${GAMMA}%\\nBrightness: ${BRIGHTNESS}%${NEXT_PERIOD_INFO}\"}"
  else
    echo "{\"text\": \"$BRIGHTNESS\", \"alt\": \"stopped\", \"tooltip\": \"sunsetr not running\\nBrightness: ${BRIGHTNESS}%\"}"
  fi
}

toggle_preset() {
  SUNSETR_STATUS=$(sunsetr status --json 2>/dev/null)
  PERIOD=$(echo "$SUNSETR_STATUS" | jq -r '.period // "static"')
  PRESET=$(echo "$SUNSETR_STATUS" | jq -r '.active_preset // "default"')

  if [ "$PRESET" != "default" ]; then
    # On any non-default preset → go back to default/geo
    # IPC daemon handles theme instantly via preset_changed.target_period
    sunsetr preset default >/dev/null 2>&1
  elif [ "$PERIOD" = "night" ]; then
    sunsetr preset day >/dev/null 2>&1
    set_gtk_theme "day"
  else
    # day, sunset, sunrise → override with static night
    sunsetr preset night >/dev/null 2>&1
    set_gtk_theme "night"
  fi

  pkill -RTMIN+2 waybar
}

case "$1" in
"status")
  get_status
  ;;
"toggle")
  toggle_preset
  ;;
"up")
  brightness_up
  pkill -RTMIN+2 waybar
  ;;
"down")
  brightness_down
  pkill -RTMIN+2 waybar
  ;;
*)
  echo "Usage: $0 {status|toggle|up|down}"
  exit 1
  ;;
esac

exit 0
