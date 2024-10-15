#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change

for sid in $(aerospace list-workspaces --all); do

	sketchybar --add item space.$sid left \
		--subscribe space.$sid aerospace_workspace_change \
		--set space.$sid \
		--animate tanh 5 \
		label.drawing=off \
		icon="$sid" \
		icon.padding_left=9 \
		icon.padding_right=9 \
		background.padding_left=2 \
		background.padding_right=2 \
		background.color=0x24ffffff \
		background.corner_radius=4 \
		background.height=22 \
		background.drawing=off \
		click_script="aerospace workspace $sid" \
		script="$PLUGIN_DIR/space.sh $sid"
done

sketchybar --add item separator left \
	--set separator icon="" \
	icon.font="$FONT:Regular:11.0" \
	background.padding_left=8 \
	background.padding_right=0 \
	label.drawing=off \
	associated_display=active \
	icon.color="$MAGENTA"
