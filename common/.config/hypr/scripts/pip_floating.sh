#!/bin/bash

handle() {
  case $1 in
  changefloatingmode*)
    data="${1#changefloatingmode>>}"
    window_addr="0x${data%,*}"
    floating_state="${data#*,}"

    window_title=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$window_addr\") | .title")

    if [ "$window_title" != "Picture-in-Picture" ]; then
      return
    fi

    if [[ "$floating_state" == "0" ]]; then
      hyprctl dispatch movewindow mon:DP-1 silent
      sed -i 's/float, title:Picture-in-Picture/tile, title:Picture-in-Picture/g' ~/.config/hypr/source/rules_pip.conf
      sed -i 's/monitor DP-3, title:Picture-in-Picture/monitor DP-1, title:Picture-in-Picture/g' ~/.config/hypr/source/rules_pip.conf
      # hyprctl dispatch resizewindowpixel 1406 791,address:"$window_addr"
    elif [[ "$floating_state" == "1" ]]; then
      hyprctl --batch "\
        dispatch movewindow mon:DP-3 silent;\
        dispatch resizewindowpixel exact 640 360,address:$window_addr;\
        dispatch movewindowpixel exact 20 1060,address:$window_addr;\
        dispatch pin address:$window_addr"
      sed -i 's/tile, title:Picture-in-Picture/float, title:Picture-in-Picture/g' ~/.config/hypr/source/rules_pip.conf
      sed -i 's/monitor DP-1, title:Picture-in-Picture/monitor DP-3, title:Picture-in-Picture/g' ~/.config/hypr/source/rules_pip.conf
    fi
    ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
  handle "$line"
done
