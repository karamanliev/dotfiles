#!/usr/bin/env bash
if pgrep -x "steam" >/dev/null; then
    pkill -x "steam"

    while pgrep -x "steam" >/dev/null; do
        sleep 1
    done
fi

steam -gamepadui &
