#!/usr/bin/env bash

COLOR="$WHITE"

sketchybar --add item battery right \
	--set battery \
	update_freq=60 \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	label.padding_right=2 \
	label.color="$COLOR" \
	script="$PLUGIN_DIR/power.sh" \
	--subscribe battery power_source_change
