#!/bin/sh -e

video_path="$HOME/Videos/Recordings/Replays"
killall -SIGUSR1 gpu-screen-recorder && sleep 0.5 && notify-send -a "GPU Screen Recorder" -i camera-video-symbolic "Replay saved." "Saving video in $video_path"
