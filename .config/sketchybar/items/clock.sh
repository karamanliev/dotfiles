#!/usr/bin/env bash

COLOR="$WHITE"

sketchybar --add item clock right \
	--set clock update_freq=10 \
	icon.padding_left=10 \
	icon.color="$COLOR" \
	icon="" \
	label.color="$COLOR" \
	click_script="osascript $MAIN_DIR/open_sidebar.applescript" \
	script="$PLUGIN_DIR/clock.sh"
