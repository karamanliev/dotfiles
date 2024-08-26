#!/bin/bash

source ~/.config/hypr/scripts/hide_special_on_ws_change.sh

hyprctl dispatch focusworkspaceoncurrentmonitor $1
