#!/bin/sh -e
killall -SIGINT gpu-screen-recorder && sleep 0.5 && notify-send --hint=int:transient:1 -a "GPU Screen Recorder" -i media-playback-stop-symbolic "Stopped recording." && exit 0
source gpu-screen-recorder-record-start.sh
