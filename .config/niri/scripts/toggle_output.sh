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
  niri msg output "DP-1" off
  niri msg output "DP-3" off
  niri msg output "HDMI-A-1" on
  switch_audio_output "hdmi"
}

switch_to_pc() {
  niri msg output "DP-1" on
  niri msg output "DP-3" on
  niri msg output "HDMI-A-1" off
  switch_audio_output "onyx"
}

# Check if HDMI is not connected then setup TV mode
monitors=$(niri msg outputs)
if echo "$monitors" | grep -A 1 'HDMI-A' | grep -q 'Disabled'; then
  switch_to_tv
  sleep 2
  steam-bigpicture.sh
else
  switch_to_pc
  ~/.config/niri/scripts/wallpaper.sh current
fi
