#!/bin/bash
[ -z "$NVIM_SERVER" ] && exit 0

TMPFILE=$(mktemp /tmp/yazi-qf-XXXXXX)
printf '%s\n' "$@" > "$TMPFILE"
nvim --server "$NVIM_SERVER" --remote-send "<cmd>QuickfixFromFile ${TMPFILE}<CR>"

if [ "${YAZI_KILL_PANE}" = "true" ]; then
  SESSION=$(tmux display-message -p '#S')
  WINDOW=$(tmux display-message -p '#I')
  tmux set-option -w -t "${SESSION}:${WINDOW}" -u @yazi_pane 2>/dev/null
  tmux kill-pane
fi
