#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh" # Loads all defined colors

SPACE_ICONS=("1" "2" "3" "4" "5" "6")

SPACE_CLICK_SCRIPT="aerospace workspace $SID"

if [ $SID = "$FOCUSED_WORKSPACE" ]; then
	sketchybar --animate tanh 5 --set "$NAME" \
		icon.color="$WHITE" \
		icon="${SPACE_ICONS[$SID - 1]}" \
		background.drawing=on \
		click_script="$SPACE_CLICK_SCRIPT"
else
	sketchybar --animate tanh 5 --set "$NAME" \
		icon.color="$COMMENT" \
		icon="${SPACE_ICONS[$SID - 1]}" \
		background.drawing=off \
		click_script="$SPACE_CLICK_SCRIPT"
fi
