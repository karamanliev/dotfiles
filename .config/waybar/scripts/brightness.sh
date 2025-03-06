#!/bin/bash
get_brightness() {
  ddcutil -b 1 --skip-ddc-checks getvcp 10 -t | perl -nE 'if (/ C (\d+) /) { say $1; }'
}

get_status() {
  local BRIGHTNESS=$(get_brightness)

  if pgrep wlsunset >/dev/null 2>&1; then
    stdbuf -oL printf '{"alt": "on", "text": "'$BRIGHTNESS'"}'
  else
    stdbuf -oL printf '{"alt": "off", "text": "'$BRIGHTNESS'"}'
  fi
}

brightness_up() {
  if [ ! -f /tmp/brightness_throttle ]; then
    touch /tmp/brightness_throttle

    ddcutil --noverify --skip-ddc-checks -b 4 setvcp 10 + 10 &
    ddcutil --noverify --skip-ddc-checks -b 1 setvcp 10 + 10 &
    wait

    sleep 0.2

    rm /tmp/brightness_throttle
  fi
}

brightness_down() {
  if [ ! -f /tmp/brightness_throttle ]; then
    touch /tmp/brightness_throttle

    ddcutil --noverify --skip-ddc-checks -b 4 setvcp 10 - 10 &
    ddcutil --noverify --skip-ddc-checks -b 1 setvcp 10 - 10 &
    wait

    sleep 0.2

    rm /tmp/brightness_throttle
  fi
}

toggle_wlsunset() {
  if pgrep wlsunset >/dev/null 2>&1; then
    killall -9 wlsunset >/dev/null 2>&1
  else
    longitude="27.910543"
    latitude="43.204666"
    wlsunset -l $latitude -L $longitude >/dev/null 2>&1 &
  fi
  pkill -35 waybar
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
"toggle")
  toggle_wlsunset
  ;;
*)
  echo "Usage: $0 {status|up|down|toggle}"
  exit 1
  ;;
esac

exit 0
