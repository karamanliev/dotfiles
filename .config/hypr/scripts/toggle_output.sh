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
  sed -i 's/pc/tv/' $HOME/.config/hypr/source/monitors.conf
  switch_audio_output "hdmi"
}

switch_to_pc() {
  sed -i 's/tv/pc/' $HOME/.config/hypr/source/monitors.conf
  switch_audio_output "onyx"
}

# Check if HDMI is not connected then setup TV mode
monitors=$(hyprctl monitors)
if echo "$monitors" | grep -i "hdmi"; then
  switch_to_pc
  hyprctl reload
  waybar &
else
  switch_to_tv
  sleep 2
  $HOME/.config/hypr/scripts/gamemode.sh on
  hyprctl dispatch workspace 9
  steam-bigpicture.sh
fi
