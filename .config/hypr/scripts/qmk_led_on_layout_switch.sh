#!/usr/bin/env bash
SCRIPT_PATH="/home/ico/.config/hypr/scripts/qmk_led_on_layout_switch.py"

function handle {
  case $1 in
  activelayout*)
    args="${1#activelayout>>}"

    lang="${args#*,}"

    if echo "$lang" | grep -q "English"; then
      python3 "$SCRIPT_PATH" en
    else
      python3 "$SCRIPT_PATH" bg
    fi
    ;;
  esac

}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
