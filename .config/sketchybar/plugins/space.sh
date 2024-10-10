#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh" # Loads all defined colors

ICONS=("1" "2" "3" "4" "5" "6" "C")
SPACE_CLICK_SCRIPT="aerospace workspace $SID"

EMPTY_WORKSPACES=$(aerospace list-workspaces --monitor all --empty)

if echo "$EMPTY_WORKSPACES" | grep -q "$SID"; then
	ICON_COLOR="$COMMENT"
else
	ICON_COLOR="$WHITE"
fi

if [ $SID = "$FOCUSED_WORKSPACE" ]; then
	sketchybar --animate tanh 5 --set "$NAME" \
		icon="${ICONS[$SID - 1]}" \
		icon.color="$ICON_COLOR" \
		background.drawing=on \
		click_script="$SPACE_CLICK_SCRIPT"
else
	sketchybar --animate tanh 5 --set "$NAME" \
		icon="${ICONS[$SID - 1]}" \
		icon.color="$ICON_COLOR" \
		background.drawing=off \
		click_script="$SPACE_CLICK_SCRIPT"
fi
