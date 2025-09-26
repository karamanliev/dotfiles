#!/bin/bash

focused_monitor_name=$(hyprctl monitors -j | jq -r '.[] | select (.focused == true) | .name')
focused_monitor_active_ws=$(hyprctl monitors -j | jq -r '.[] | select (.focused == true) | .activeWorkspace.id')

inactive_monitor_name=$(hyprctl monitors -j | jq -r '.[] | select (.focused == false) | .name')
inactive_monitor_active_ws=$(hyprctl monitors -j | jq -r '.[] | select (.focused == false) | .activeWorkspace.id')

workspaces=6

if [ "$1" == "next" ]; then
  next_ws=$((focused_monitor_active_ws + 1))

  if [ $next_ws -eq $inactive_monitor_active_ws ]; then
    next_ws=$((focused_monitor_active_ws + 2))
  fi

  if [ $next_ws -gt $workspaces ]; then
    if [ $inactive_monitor_active_ws -eq 1 ]; then
      next_ws=2
    else
      next_ws=1
    fi
  fi

  if [ "$2" == "move" ]; then
    hyprctl dispatch movetoworkspace $next_ws
  fi

  hyprctl dispatch moveworkspacetomonitor $next_ws $focused_monitor_name
  hyprctl dispatch workspace $next_ws

elif [ "$1" == "prev" ]; then
  prev_ws=$((focused_monitor_active_ws - 1))

  if [ $prev_ws -eq $inactive_monitor_active_ws ]; then
    prev_ws=$((focused_monitor_active_ws - 2))
  fi

  if [ $prev_ws -lt 1 ]; then
    if [ $inactive_monitor_active_ws -eq $workspaces ]; then
      prev_ws=$((workspaces - 1))
    else
      prev_ws=$workspaces
    fi
  fi

  if [ "$2" == "move" ]; then
    hyprctl dispatch movetoworkspace $prev_ws
  fi

  hyprctl dispatch moveworkspacetomonitor $prev_ws $focused_monitor_name
  hyprctl dispatch workspace $prev_ws
fi
