#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change

for i in $(aerospace list-workspaces --monitor all); do
	sketchybar --add space space.$i left \
		--subscribe space.$i aerospace_workspace_change system_woke \
		--set space.$i associated_space=$i \
		label.drawing=off \
		icon.padding_left=9 \
		icon.padding_right=9 \
		background.padding_left=2 \
		background.padding_right=2 \
		background.color=0x24ffffff \
		background.corner_radius=4 \
		background.height=22 \
		background.drawing=off \
		script="$PLUGIN_DIR/space.sh"
done

sketchybar --add item separator left \
	--set separator icon="" \
	icon.font="$FONT:Regular:11.0" \
	background.padding_left=8 \
	background.padding_right=0 \
	label.drawing=off \
	associated_display=active \
	icon.color="$MAGENTA"
