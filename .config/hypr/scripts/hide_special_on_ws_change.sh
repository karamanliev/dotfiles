#!/bin/bash

# If the focused workspace is a special workspace, hide it when switching to another workspace with SUPER+TAB, SUPER_1, SUPER_2, etc.
special_name=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .specialWorkspace.name' | sed 's/^special://')
hide_action="hyprctl dispatch togglespecialworkspace $special_name"
