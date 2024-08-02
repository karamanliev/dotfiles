#!/bin/sh
killall -SIGINT gpu-screen-recorder && sleep 0.5 && notify-send --hint=int:transient:1 -a "GPU Screen Recorder" -i media-playback-stop-symbolic "Replay recording service has stopped."
