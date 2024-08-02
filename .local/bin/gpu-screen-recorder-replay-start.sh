#!/bin/sh
pidof -q gpu-screen-recorder && exit 1
video_path="$HOME/Videos/Recordings/Replays"
mkdir -p "$video_path"
notify-send --hint=int:transient:1 -a "GPU Screen Recorder" -i media-record-symbolic "Replay recording service has started."
gpu-screen-recorder -w "DP-3" -f 60 -a "$(pactl get-default-sink).monitor|$(pactl get-default-source)" -c mp4 -r 45 -o "$video_path"
