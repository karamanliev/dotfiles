#!/usr/bin/env bash

COLOR="$WHITE"

sketchybar \
	--add item sound right \
	--set sound \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	label.color="$COLOR" \
	label.padding_right=2 \
	script="$PLUGIN_DIR/sound.sh" \
	--subscribe sound volume_change
