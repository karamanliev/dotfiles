#!/bin/bash
# Usage: toggle-popup.sh <session_name> <pane_path> <popup_name> [popup_command...]
# If currently inside any popup session:
#   - same popup key pressed: just close (toggle off)
#   - different popup key pressed: signal switch via tmux session options, then detach
# Otherwise: open popup in a loop, reopening with next popup if signalled.

session="$1"
path="$2"
popup_name="$3"
shift 3

if echo "$session" | grep -q -- "-popup$"; then
  current_name=$(echo "$session" | sed 's/.*_\([^_]*\)-popup$/\1/')
  parent_session=$(echo "$session" | sed 's/_[^_]*-popup$//')

  if [ "$popup_name" != "$current_name" ] && [ $# -gt 0 ]; then
    # Different popup requested — signal the parent loop via tmux session options
    next_cmd=$(printf '%s ' "$@" | sed "s|${session}|${parent_session}|g")
    tmux set-option -t "$parent_session" @next_popup_path "$path"
    tmux set-option -t "$parent_session" @next_popup_cmd "$next_cmd"
  fi
  tmux detach-client
else
  declare -a popup_args=("$@")
  current_path="$path"

  while true; do
    tmux set-option -t "$session" -u @next_popup_cmd 2>/dev/null
    tmux set-option -t "$session" -u @next_popup_path 2>/dev/null
    tmux display-popup -E -xC -yS -w98% -h98% -d "$current_path" "${popup_args[@]}"

    next_cmd=$(tmux show-option -qv -t "$session" @next_popup_cmd 2>/dev/null)
    if [ -n "$next_cmd" ]; then
      current_path=$(tmux show-option -qv -t "$session" @next_popup_path 2>/dev/null)
      popup_args=(bash -c "$next_cmd")
    else
      break
    fi
  done
fi
