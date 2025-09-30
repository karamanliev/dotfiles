#!/bin/sh

monitor="$1"
parent_pid=$PPID

get_window_count() {
  if [ -n "$monitor" ]; then
    idfocused="$(niri msg -j workspaces | jq -r ".[] | select(.output == \"$monitor\" and .is_focused == true) | .id")"
    if [ -z "$idfocused" ] || [ "$idfocused" = "null" ]; then
      # Get the active workspace on this monitor even if not focused
      workspace_id="$(niri msg -j workspaces | jq -r ".[] | select(.output == \"$monitor\" and .is_active == true) | .id")"
    else
      workspace_id="$idfocused"
    fi
  else
    idfocused="$(niri msg -j workspaces | jq ".[] | select(.is_focused == true ) | .id")"
    workspace_id="$idfocused"
  fi

  if [ -z "$workspace_id" ] || [ "$workspace_id" = "null" ]; then
    printf "0\n"
  else
    windows="$(niri msg -j windows | jq "[.[] | select(.workspace_id == $workspace_id)] | sort_by(.layout.pos_in_scrolling_layout[0])")"
    num="$(echo "$windows" | jq "length")"
    focused_pos="$(echo "$windows" | jq "map(.is_focused) | index(true) + 1")"
    if [ "$num" -le 1 ]; then
      printf "%d\n" "$num"
    elif [ "$focused_pos" = "null" ]; then
      printf "%d\n" "$num"
    else
      printf "%d / %d\n" "$focused_pos" "$num"
    fi
  fi
}

get_window_count

event_count=0
niri msg event-stream |
  while read -r line; do
    case "$line" in
    "Window opened"* | "Window closed"* | "Workspace focused"* | "Window focus changed"*)
      get_window_count

      # Check every 10 events if parent process still exists
      event_count=$((event_count + 1))
      if [ $((event_count % 10)) -eq 0 ]; then
        if ! kill -0 "$parent_pid" 2>/dev/null; then
          exit 0
        fi
      fi
      ;;
    esac
  done
