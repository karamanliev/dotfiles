#!/usr/bin/env bash
source "$HOME/.config/sketchybar/variables.sh" # Loads all defined colors

if echo "$EMPTY_WORKSPACES" | grep -q "$1"; then
	ICON_COLOR="$COMMENT"
else
	ICON_COLOR="$WHITE"
fi

echo "FOCUSED_WORKSPACE: $FOCUSED_WORKSPACE"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
	sketchybar --set $NAME \
		background.drawing=on \
		icon.color="$ICON_COLOR"
else
	sketchybar --set $NAME \
		background.drawing=off \
		icon.color="$ICON_COLOR"
fi
