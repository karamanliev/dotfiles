#!/bin/bash
# Usage: toggle-popup.sh <session_name> <pane_path> <popup_command>
# If currently inside any popup session: detach (close popup).
# Otherwise: open a popup running the given command.
session="$1"
path="$2"
shift 2

if echo "$session" | grep -q -- "-popup$"; then
  tmux detach-client
else
  tmux display-popup -E -xC -yS -w98% -h98% -d "$path" "$@"
fi
