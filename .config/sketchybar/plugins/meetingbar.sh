#!/usr/bin/env bash
ITEM_SIZE=$(sketchybar --query meetingbar_alias | grep size | sed 's/.*\[ //' | awk -F',' '{print int($1)}')

if [ "$ITEM_SIZE" -lt 60 ]; then
	VISIBLE="off"
else
	VISIBLE="on"
fi

sketchybar --set "$NAME" \
	drawing=$VISIBLE
