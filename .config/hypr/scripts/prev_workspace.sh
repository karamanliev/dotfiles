#!/bin/bash

source ~/.config/hypr/scripts/hide_special_on_ws_change.sh

if [ "$special_name" ]; then
  $hide_action
else
  hyprctl dispatch workspace previous
fi
