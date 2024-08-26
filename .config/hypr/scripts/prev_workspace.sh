#!/bin/bash
special_name=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .specialWorkspace.name' | sed 's/^special://')

if [ "$special_name" ]; then
  hyprctl dispatch togglespecialworkspace "$special_name"

else
  hyprctl dispatch workspace previous
fi
