#!/usr/bin/env bash

COLOR="$CYAN"

sketchybar --add item memory q \
	--set memory \
	update_freq=3 \
	icon.color="$WHITE" \
	label.color="$WHITE" \
	icon.padding_left=8 \
	click_script="kitty -e 'btop'" \
	script="$PLUGIN_DIR/memory.sh"
