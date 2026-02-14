#!/bin/bash
filename="$1"

if [ -n "$NVIM_SERVER" ]; then
  nvim --server "$NVIM_SERVER" --remote-send "<cmd>e ${filename}<cr>"
  if [ "${YAZI_KILL_PANE}" = "true" ]; then
    tmux kill-pane
  # This focuses the nvim pane on file open
  # else
  #   SESSION=$(tmux display-message -p '#S')
  #   WINDOW=$(tmux display-message -p '#I')
  #   NVIM_PANE=$(tmux list-panes -t "${SESSION}:${WINDOW}" -F "#{pane_id} #{@nvim_server}" 2>/dev/null \
  #     | grep " ${NVIM_SERVER}$" | awk '{print $1}')
  #   [ -n "$NVIM_PANE" ] && tmux select-pane -t "$NVIM_PANE"
  fi
else
  nvim "$filename"
fi
