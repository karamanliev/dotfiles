#!/bin/bash
# Brightness backend for laptop (brightnessctl)

get_brightness() {
  brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/, "", $4); print $4}'
}

brightness_up() {
  brightnessctl set +5% >/dev/null 2>&1
}

brightness_down() {
  brightnessctl set 5%- >/dev/null 2>&1
}
