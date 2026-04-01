#!/usr/bin/env sh

command -v upower >/dev/null 2>&1 || exit 0

battery_device="/org/freedesktop/UPower/devices/battery_BAT0"

devices="$(upower -e 2>/dev/null)"
printf '%s\n' "$devices" | awk -v dev="$battery_device" '$0 == dev { found = 1 } END { exit !found }' || exit 0

info="$(upower -i "$battery_device" 2>/dev/null)"
[ -n "$info" ] || exit 0

get_upower_field() {
  key="$1"
  printf '%s\n' "$info" | awk -F: -v key="$key" '
    $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      value = $2
      sub(/^[[:space:]]+/, "", value)
      gsub(/\047/, "", value)
      print value
      exit
    }
  '
}

percentage="$(get_upower_field percentage | tr -d '[:space:]')"
icon_name="$(get_upower_field icon-name)"

[ -n "$percentage" ] || exit 0

case "$icon_name" in
*charging*)
  icon="󰂄"
  ;;
*full*)
  icon="󰁹"
  ;;
*good*)
  icon="󰁽"
  ;;
*low*)
  icon="󰁻"
  ;;
*caution*)
  icon="󰁺"
  ;;
*empty*)
  icon="󰂎"
  ;;
*)
  icon="󰂑"
  ;;
esac

printf '#[default]%s #[fg=#{fg_color}]%s' "$icon" "$percentage"
