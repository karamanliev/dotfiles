#!/bin/bash
get_brightness() {
  ddcutil -b 1 --skip-ddc-checks getvcp 10 -t | perl -nE 'if (/ C (\d+) /) { say $1; }'
}

is_sunsetr_running() {
  pgrep -x sunsetr >/dev/null 2>&1
}

get_active_preset() {
  if is_sunsetr_running; then
    sunsetr p active 2>/dev/null || echo "unknown"
  else
    echo "stopped"
  fi
}

get_status() {
  local BRIGHTNESS=$(get_brightness)
  local ACTIVE_PRESET=$(get_active_preset)

  case "$ACTIVE_PRESET" in
  "day")
    printf '{"alt": "day", "text": "'$BRIGHTNESS'"}'
    ;;
  "night")
    printf '{"alt": "night", "text": "'$BRIGHTNESS'"}'
    ;;
  "default")
    printf '{"alt": "auto", "text": "'$BRIGHTNESS'"}'
    ;;
  "stopped")
    printf '{"alt": "stopped", "text": "'$BRIGHTNESS'"}'
    ;;
  *)
    printf '{"alt": "unknown", "text": "'$BRIGHTNESS'"}'
    ;;
  esac
}

brightness_up() {
  if [ ! -f /tmp/brightness_throttle ]; then
    touch /tmp/brightness_throttle

    ddcutil --noverify --skip-ddc-checks -b 4 setvcp 10 + 5 &
    ddcutil --noverify --skip-ddc-checks -b 1 setvcp 10 + 5 &
    wait

    sleep 0.2

    rm /tmp/brightness_throttle
  fi
}

brightness_down() {
  if [ ! -f /tmp/brightness_throttle ]; then
    touch /tmp/brightness_throttle

    ddcutil --noverify --skip-ddc-checks -b 4 setvcp 10 - 5 &
    ddcutil --noverify --skip-ddc-checks -b 1 setvcp 10 - 5 &
    wait

    sleep 0.2

    rm /tmp/brightness_throttle
  fi
}

cycle_sunsetr() {
  if ! is_sunsetr_running; then
    sunsetr preset default >/dev/null 2>&1 &
  else
    local ACTIVE_PRESET=$(get_active_preset)
    sunsetr set --target default smoothing=false >/dev/null 2>&1

    case "$ACTIVE_PRESET" in
    "default")
      sunsetr preset day >/dev/null 2>&1 &
      ;;
    "day")
      sunsetr preset night >/dev/null 2>&1 &
      ;;
    "night")
      sunsetr preset default >/dev/null 2>&1 &
      ;;
    *)
      sunsetr preset default >/dev/null 2>&1 &
      ;;
    esac

    sleep 0.1
    sunsetr set --target default smoothing=true >/dev/null 2>&1
  fi

  pkill -RTMIN+1 waybar
}

case "$1" in
"status")
  get_status
  ;;
"up")
  brightness_up
  ;;
"down")
  brightness_down
  ;;
"cycle")
  cycle_sunsetr
  ;;
*)
  echo "Usage: $0 {status|up|down|cycle}"
  exit 1
  ;;
esac

exit 0
