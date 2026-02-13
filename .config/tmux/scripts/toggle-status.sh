#!/bin/bash
session="${1:-$(tmux display-message -p '#{session_name}')}"

# Only apply to Claude and scratch popup sessions
[[ ! "$session" =~ (_claude-popup|_scratch-popup)$ ]] && exit 0

count=$(tmux list-windows -t "$session" 2>/dev/null | wc -l)
[ "$count" -gt 1 ] && tmux set-option -t "$session" status on || tmux set-option -t "$session" status off
