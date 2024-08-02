#!/bin/sh -e

killall -SIGUSR1 gpu-screen-recorder && sleep 0.5 && notify-send -a "GPU Screen Recorder" -i camera-video-symbolic "Replay saved."
