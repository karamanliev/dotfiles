#!/bin/bash

switch_audio_output() {
    sleep 1

    local sink_type=$1
    sink_id=$(pactl list short sinks | grep -i "$sink_type" | awk '{print $1}')

    if [ -n "$sink_id" ]; then
        pactl set-default-sink "$sink_id"
    fi
}

switch_to_tv() {
    gnome-monitor-config set -LpM HDMI-1 -m 3840x2160@60.000
    switch_audio_output "hdmi"
}

switch_to_pc() {
    gnome-monitor-config set -LpM DP-3 -m 2560x1440@165.080 -LM DP-1 -x 2560 -y 0 -m 2560x1440@165.080
    switch_audio_output "onyx"
}

# Check if HDMI is not connected then setup TV mode
if gnome-monitor-config list | grep -i "hdmi" | grep -q "OFF"; then
    switch_to_tv
else
    switch_to_pc
fi
