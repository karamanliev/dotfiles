#!/usr/bin/env sh

command -v upower >/dev/null 2>&1 || exit 0

info="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null)"
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
status="$(get_upower_field state | tr '[:upper:]' '[:lower:]')"
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
