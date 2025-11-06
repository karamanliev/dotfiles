#!/bin/bash

BRIGHTNESS_CACHE="/tmp/brightness_cache"
BRIGHTNESS_THROTTLE="/tmp/brightness_throttle"

read_brightness() {
  ddcutil -b 1 --skip-ddc-checks getvcp 10 -t | perl -nE 'if (/ C (\d+) /) { say $1; }'
}

update_brightness_cache() {
  read_brightness >"$BRIGHTNESS_CACHE"
}

get_brightness() {
  if [ -f "$BRIGHTNESS_CACHE" ]; then
    cat "$BRIGHTNESS_CACHE"
  else
    BRIGHTNESS=$(read_brightness)
    echo "$BRIGHTNESS" >"$BRIGHTNESS_CACHE"
    echo "$BRIGHTNESS"
  fi
}

get_status() {
  trap 'exit 0' SIGTERM SIGINT

  while true; do
    BRIGHTNESS=$(get_brightness)
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

    sleep 2
  done
}

toggle_preset() {
  local PERIOD=$(sunsetr status --json 2>/dev/null | jq -r '.active_period // "day"')

  if [ "$PERIOD" = "night" ]; then
    sunsetr preset day >/dev/null 2>&1
  else
    sunsetr preset night >/dev/null 2>&1
  fi
}

brightness_up() {
  if [ ! -f "$BRIGHTNESS_THROTTLE" ]; then
    touch "$BRIGHTNESS_THROTTLE"

    ddcutil --noverify --skip-ddc-checks -b 4 setvcp 10 + 5 &
    ddcutil --noverify --skip-ddc-checks -b 1 setvcp 10 + 5 &
    wait

    update_brightness_cache

    sleep 0.2

    rm "$BRIGHTNESS_THROTTLE"
  fi
}

brightness_down() {
  if [ ! -f "$BRIGHTNESS_THROTTLE" ]; then
    touch "$BRIGHTNESS_THROTTLE"

    ddcutil --noverify --skip-ddc-checks -b 4 setvcp 10 - 5 &
    ddcutil --noverify --skip-ddc-checks -b 1 setvcp 10 - 5 &
    wait

    update_brightness_cache

    sleep 0.2

    rm "$BRIGHTNESS_THROTTLE"
  fi
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
  ;;
"down")
  brightness_down
  ;;
*)
  echo "Usage: $0 {status|toggle|up|down}"
  exit 1
  ;;
esac

exit 0
