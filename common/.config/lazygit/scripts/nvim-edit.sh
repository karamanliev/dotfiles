#!/bin/bash
filename="$1"
line="$2"

# Resolve nvim server: static from LazyGit nvim command, or live lookup for popup context
SRV=${NVIM_SERVER}
if [ -z "$SRV" ] && [ -n "${LAZYGIT_PARENT_SESSION}" ]; then
  PARENT_WINDOW=$(tmux show-options -v -t "${LAZYGIT_POPUP_SESSION}" @lazygit_parent_window 2>/dev/null)
  SRV=$(tmux list-panes -t "${LAZYGIT_PARENT_SESSION}:${PARENT_WINDOW}" \
    -F "#{@nvim_server}" 2>/dev/null | grep -v "^$" | head -1)
fi

if [ -n "$SRV" ]; then
  if [ -n "$line" ]; then
    nvim --server "$SRV" --remote-send "<cmd>e +${line} ${filename}<cr>"
  else
    nvim --server "$SRV" --remote-send "<cmd>e ${filename}<cr>"
  fi
  if [ -n "${LAZYGIT_POPUP_SESSION}" ]; then
    tmux detach-client
  elif [ "${LAZYGIT_KILL_PANE}" = "true" ]; then
    tmux kill-pane
  fi
elif [ -n "${LAZYGIT_POPUP_SESSION}" ]; then
  if [ -n "$line" ]; then
    tmux new-window -t "${LAZYGIT_PARENT_SESSION}" "nvim +${line} ${filename}"
    # don't close the window on exit
    # tmux new-window -t "${LAZYGIT_PARENT_SESSION}" "nvim +${line} ${filename}; exec $SHELL"
  else
    tmux new-window -t "${LAZYGIT_PARENT_SESSION}" "nvim ${filename}"
    # don't close the window on exit
    # tmux new-window -t "${LAZYGIT_PARENT_SESSION}" "nvim ${filename}; exec $SHELL"
  fi
  tmux detach-client
fi
