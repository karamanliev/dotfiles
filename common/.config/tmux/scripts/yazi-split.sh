#!/bin/bash
SESSION="$1"
WINDOW="$2"
PANE_PATH="$3"

# Don't open inside popup sessions
if echo "$SESSION" | grep -q -- "-popup$"; then
  exit 0
fi

# Toggle: if a yazi pane is tracked for this window, kill it
YAZI_PANE=$(tmux show-options -w -v -t "${SESSION}:${WINDOW}" @yazi_pane 2>/dev/null)
if [ -n "$YAZI_PANE" ] && tmux list-panes -t "${SESSION}:${WINDOW}" -F "#{pane_id}" 2>/dev/null | grep -qF "$YAZI_PANE"; then
  tmux kill-pane -t "$YAZI_PANE"
  tmux set-option -w -t "${SESSION}:${WINDOW}" -u @yazi_pane 2>/dev/null
  exit 0
fi

# Find nvim server in the current window
SRV=$(tmux list-panes -t "${SESSION}:${WINDOW}" -F "#{@nvim_server}" 2>/dev/null | grep -v "^$" | head -1)

# Determine which file to focus in yazi
# $4 can be passed directly by the Yazi nvim command to avoid a deadlock
# (silent ! blocks nvim's event loop so --remote-expr would hang)
YAZI_CMD="yazi"
CURRENT_FILE="${4:-}"
if [ -f "$CURRENT_FILE" ]; then
  YAZI_CMD="yazi '$CURRENT_FILE'"
elif [ -n "$SRV" ]; then
  CURRENT_FILE=$(nvim --server "$SRV" --remote-expr "expand('%:p')" 2>/dev/null | tr -d '\n')
  [ -f "$CURRENT_FILE" ] && YAZI_CMD="yazi '$CURRENT_FILE'"
fi

KILL_PANE="true"
PANE_SIZE=""
PANE_POS=""

# Orientation: horizontal if window is at least 2x wider than tall, else vertical
WIDTH=$(tmux display-message -p -t "${SESSION}:${WINDOW}" "#{window_width}")
HEIGHT=$(tmux display-message -p -t "${SESSION}:${WINDOW}" "#{window_height}")
ORIENTATION="-h"
ZOOM_FLAG="-Z"
if [ "$WIDTH" -lt $((HEIGHT * 2)) ]; then
  ORIENTATION="-v"
  ZOOM_FLAG=""
fi

# $6: if set, use this flag to kill the pane
if [ -n "${6:-}" ]; then
  KILL_PANE="${6}"
fi

PANE_ID=$(tmux split-window -t "${SESSION}:${WINDOW}" $ORIENTATION $ZOOM_FLAG $PANE_SIZE $PANE_POS -c "$PANE_PATH" -P -F "#{pane_id}" \
  "env NVIM_SERVER='${SRV}' YAZI_KILL_PANE=${KILL_PANE} ${YAZI_CMD}; tmux set-option -w -t '${SESSION}:${WINDOW}' -u @yazi_pane 2>/dev/null; tmux kill-pane")

tmux set-option -w -t "${SESSION}:${WINDOW}" @yazi_pane "$PANE_ID"
