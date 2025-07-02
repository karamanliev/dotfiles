#!/usr/bin/env bash

monitor_data=$(hyprctl monitors -j)

EXCLUDED_CLASSES=("org.gnome.Calculator" "com.gabm.satty" "system_monitor_btop" "zen")
EXCLUDED_TITLES=()
EXCLUDED_CLASSES_TITLE=("org.gnome.Nautilus " "zen Picture-in-Picture")

function should_skip_class_or_title {
  local real_address="$1"
  local client_data class title class_title

  client_data=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$real_address\") | \"\\(.class)\\t\\(.title)\"")
  echo "client_data: ${client_data}"
  [[ -z "$client_data" ]] && return 1

  IFS=$'\t' read -r class title <<<"$client_data"
  echo "class: ${class}"
  echo "title: ${title}"
  class_title="$class $title"

  local excluded
  for excluded in "${EXCLUDED_CLASSES[@]}" "${EXCLUDED_TITLES[@]}" "${EXCLUDED_CLASSES_TITLE[@]}"; do
    if [[ "$class" == "$excluded" || "$title" == "$excluded" || "$class_title" == "$excluded" ]]; then
      echo "skipping $excluded"
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
