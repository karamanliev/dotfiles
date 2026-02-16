#!/usr/bin/env bash

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
enabled_app_classes=("steam_app*" "ELDEN RING*")
opened_app_address=""

function match_pattern {
  local class=$1
  for pattern in "${enabled_app_classes[@]}"; do
    if [[ "$class" == $pattern ]]; then
      return 0 # match found
    fi
  done
  return 1 # no match
}

function handle {
  case $1 in
  openwindow*)
    args="${1#openwindow>>}"
    address=$(echo "$args" | cut -d',' -f1)
    class=$(echo "$args" | cut -d',' -f3)

    if match_pattern "$class"; then
      opened_app_address=$address

      if [ "$HYPRGAMEMODE" = 1 ]; then
        hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"
      fi

    fi
    ;;

  closewindow*)
    address="${1#closewindow>>}"

    if [ "$opened_app_address" == "$address" ]; then
      hyprctl reload
      echo "reload"
    fi

    ;;
  esac

}
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
