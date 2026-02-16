#!/usr/bin/env bash
function handle {
  case $1 in
  workspacev2*)
    SPECIAL_WS=$(hyprctl monitors -j | jq -r '.[] | select (.focused == true) | .specialWorkspace.name' | sed 's/^special://')

    if [[ "$SPECIAL_WS" ]]; then
      hyprctl dispatch togglespecialworkspace "$SPECIAL_WS"
    fi
    ;;
  esac

}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
