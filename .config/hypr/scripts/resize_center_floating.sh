#!/usr/bin/env bash

function handle {
  case $1 in
  changefloatingmode*)
    args="${1#changefloatingmode>>}"

    address="${args%,*}"
    floating="${args#*,}"
    real_address="0x$address"

    if [ "$floating" = 1 ]; then
      hyprctl --batch "\
        dispatch resizewindowpixel exact 65% 65%,address:${real_address};\
        dispatch centerwindow"
    fi
    ;;
  esac

}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
