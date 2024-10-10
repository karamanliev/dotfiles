#!/usr/bin/env bash

COLOR="$CYAN"

sketchybar --add item vpn q \
	--set vpn \
	update_freq=3 \
	label.color="$WHITE" \
	icon.color="$WHITE" \
	icon.padding_left=8 \
	label.padding_right=0 \
	script="$PLUGIN_DIR/vpn.sh"
