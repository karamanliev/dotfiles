#!/usr/bin/env bash

COLOR="$WHITE"

sketchybar --add item calendar right \
	--set calendar update_freq=15 \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	label.color="$COLOR" \
	label.padding_right=2 \
	script="$PLUGIN_DIR/calendar.sh"
