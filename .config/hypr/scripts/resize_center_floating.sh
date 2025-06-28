#!/usr/bin/env bash

monitor_data=$(hyprctl monitors -j)

EXCLUDED_CLASSES=("org.gnome.Calculator" "com.gabm.satty" "system_monitor_btop" "zen")
EXCLUDED_TITLES=("Picture-in-Picture")

function should_skip_class_or_title {
  local real_address="$1"
  local class title

  class=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$real_address\").class")
  title=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$real_address\").title")

  for excluded in "${EXCLUDED_CLASSES[@]}"; do
    if [[ "$class" == "$excluded" ]]; then
      echo "skipping $class"
      return 0
    fi
  done

  for excluded in "${EXCLUDED_TITLES[@]}"; do
    if [[ "$title" == "$excluded" ]]; then
      echo "skipping $title"
      return 0
    fi
  done

  return 1
}

function get_monitor_and_transform {
  local real_address="$1"
  local active_monitor
  active_monitor=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$real_address\").monitor")
  transform=$(echo "$monitor_data" | jq -r ".[] | select(.id == $active_monitor).transform")
}

function resize_and_center {
  local real_address="$1"
  local transform="$2"

  if [ "$transform" != 0 ]; then
    hyprctl --batch "\
      dispatch resizewindowpixel exact 96% 40%,address:${real_address};\
      dispatch centerwindow"
  else
    hyprctl --batch "\
      dispatch resizewindowpixel exact 65% 60%,address:${real_address};\
      dispatch centerwindow"
  fi
}

function handle {
  case $1 in
  openwindow*)
    args="${1#openwindow>>}"
    address="${args%%,*}"
    real_address="0x$address"

    get_monitor_and_transform "$real_address"
    floating=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$real_address\").floating")

    if [ "$floating" = true ] && ! should_skip_class_or_title "$real_address"; then
      resize_and_center "$real_address" "$transform"
    fi
    ;;
  changefloatingmode*)
    args="${1#changefloatingmode>>}"
    address="${args%,*}"
    floating="${args#*,}"
    real_address="0x$address"

    if [ "$floating" = 1 ] && ! should_skip_class_or_title "$real_address"; then
      get_monitor_and_transform "$real_address"
      resize_and_center "$real_address" "$transform"
    fi
    ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
