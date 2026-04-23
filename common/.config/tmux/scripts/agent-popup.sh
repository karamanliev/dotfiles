#!/bin/bash

session="$1"

if [ -z "$session" ]; then
  exit 1
fi

dotfiles_root="${DOTFILES:-$HOME/dotfiles}"
if [ -f "$dotfiles_root/.env" ]; then
  set -a
  . "$dotfiles_root/.env"
  set +a
fi

agent_cmd="${AGENT_CMD:-opencode}"

tmux attach-session -t "${session}_agent-popup" || \
  tmux new-session -s "${session}_agent-popup" "$agent_cmd" \; \
    set-option -t "${session}_agent-popup" default-command "$agent_cmd"
