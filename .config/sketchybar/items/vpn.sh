#!/usr/bin/env bash

COLOR="$CYAN"

sketchybar --add item vpn q \
	--set vpn \
	update_freq=3 \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	label.color="$WHITE" \
	label.padding_right=2 \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	background.color="$BAR_COLOR" \
	background.height=24 \
	background.corner_radius="$CORNER_RADIUS" \
	background.border_width="$BORDER_WIDTH" \
	background.border_color="$COLOR" \
	background.padding_left=6 \
	background.padding_right=0 \
	background.drawing=on \
	label.padding_right=10 \
	script="$PLUGIN_DIR/vpn.sh"
