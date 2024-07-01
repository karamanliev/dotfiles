#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/Projects ~/Downloads ~/ -mindepth 1 -maxdepth 1 -type d | fzf-tmux -p 50%,50%)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name

# if default session exists and creating new session from this script, move default session windows to the new one
if tmux has-session -t=default; then
    # get session count at the time, will work if only it is 1 (default) + 1 (the new one)
    session_count=$(echo $(tmux list-sessions -F \#S) | tr ' ' '\n' | wc -l)

    # get all window ids of default session
    default_window_ids=$(tmux list-windows -t default -F \#I)
    window_count=$(echo "$default_window_ids" | wc -w)

    # move if it's only one window. Leave the session alone if more than 1 or more sessions, not just default
    if [ "$window_count" -eq 1 ] && [ "$session_count" -eq 2 ]; then
        old_window_name=$(tmux list-windows -t default -F \#W)
        tmux movew -s default:$default_window_ids -t $selected_name -d

        new_window_id=$(tmux list-windows -t $selected_name -F \#I | tail -n 1)
        tmux rename-window -t $selected_name:$new_window_id "$old_window_name: default mv"
    fi

    # commented loop will move all
    # for window_id in $default_window_ids
    # do
    #     tmux movew -s default:$window_id -t $selected_name -d
    # done
fi
