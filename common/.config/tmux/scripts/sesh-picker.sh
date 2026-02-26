#!/usr/bin/env bash
set -euo pipefail

CURRENT_THEME="$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/current_theme" 2>/dev/null || true)"
FZF_THEME_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/${CURRENT_THEME}.sh"

[[ -r "$FZF_THEME_FILE" ]] && source "$FZF_THEME_FILE"

selection="$(
  sesh list -i | fzf-tmux -p 55%,60% --layout=reverse --ansi \
    --no-sort --border-label ' sesh ' --prompt '⚡  ' \
    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'alt-s:abort' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t -i)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c -i)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z -i)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list -i)' ||
    true
)"

[[ -n "$selection" ]] || exit 0
sesh connect "$selection"
