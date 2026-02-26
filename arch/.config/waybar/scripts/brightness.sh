#!/bin/bash
# Brightness backend for desktop (ddcutil over DDC/CI)

BRIGHTNESS_CACHE="/tmp/brightness_cache"
BRIGHTNESS_LOCK="/tmp/brightness_lock"

_brightness_cleanup() {
  rmdir "$BRIGHTNESS_LOCK" 2>/dev/null
}
trap _brightness_cleanup EXIT

update_brightness_cache() {
  ddcutil -b 5 --skip-ddc-checks getvcp 10 -t 2>/dev/null | perl -nE 'if (/ C (\d+) /) { say $1; }' >"$BRIGHTNESS_CACHE"
}

get_brightness() {
  if [ ! -s "$BRIGHTNESS_CACHE" ]; then
    for _ in {1..10}; do update_brightness_cache; [ -s "$BRIGHTNESS_CACHE" ] && break; sleep 0.2; done
  fi
  [ -s "$BRIGHTNESS_CACHE" ] && cat "$BRIGHTNESS_CACHE" 2>/dev/null || echo "0"
}

brightness_up() {
  if mkdir "$BRIGHTNESS_LOCK" 2>/dev/null; then
    ddcutil --noverify --skip-ddc-checks -b 5 setvcp 10 + 5 &
    ddcutil --noverify --skip-ddc-checks -b 3 setvcp 10 + 5 &
    wait
    update_brightness_cache
    sleep 0.2
    rmdir "$BRIGHTNESS_LOCK"
  fi
}

brightness_down() {
  if mkdir "$BRIGHTNESS_LOCK" 2>/dev/null; then
    ddcutil --noverify --skip-ddc-checks -b 5 setvcp 10 - 5 &
    ddcutil --noverify --skip-ddc-checks -b 3 setvcp 10 - 5 &
    wait
    update_brightness_cache
    sleep 0.2
    rmdir "$BRIGHTNESS_LOCK"
  fi
}
