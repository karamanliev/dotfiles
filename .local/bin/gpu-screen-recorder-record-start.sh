#!/bin/sh -e
active_sink="$(pactl get-default-sink).monitor|$(pactl get-default-source)"
mkdir -p "$HOME/Videos/Recordings/"
video="$HOME/Videos/Recordings/$(date +"Video_%Y-%m-%d_%H-%M-%S.mp4")"
# notify-send -t 1500 -u low 'GPU Screen Recorder' "Started recording video to $video"
notify-send -i media-record-symbolic -a "GPU Screen Recorder" "Started recording." "Saving video to $video"
gpu-screen-recorder -w "DP-3" -c mp4 -f 60 -a "$active_sink" -o "$video"
