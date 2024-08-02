#!/bin/sh
pidof -q gpu-screen-recorder && exit 1
video_path="$HOME/Videos/Recordings/Replays"
mkdir -p "$video_path"
notify-send --hint=int:transient:1 -i media-record-symbolic -a "GPU Screen Recorder" "Replay recording service has started." "Save the last 45 seconds with Super+Shift+F5."
gpu-screen-recorder -w "DP-3" -f 60 -a "$(pactl get-default-sink).monitor|$(pactl get-default-source)" -c mp4 -r 45 -o "$video_path"
