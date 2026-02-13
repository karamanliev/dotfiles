#!/bin/bash
TMUX_SESSION="$1"
TMUX_WINDOW="$2"
SESSION="${TMUX_SESSION}_lazygit-popup"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/config_nvim.yml"

# Create the session detached if it doesn't exist yet
tmux new-session -d -s "$SESSION" \
  "env LAZYGIT_POPUP_SESSION='${SESSION}' LAZYGIT_PARENT_SESSION='${TMUX_SESSION}' lazygit -ucf '${CONFIG}'; tmux kill-session -t '${SESSION}'" 2>/dev/null || true

# Always update the parent window to whichever window opened the popup
tmux set-option -t "$SESSION" @lazygit_parent_window "$TMUX_WINDOW"

exec tmux attach-session -t "$SESSION"
