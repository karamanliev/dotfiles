#!/bin/bash

COLOR="$MAGENTA"

sketchybar --add alias "MeetingBar,Item-0" e \
	--rename "MeetingBar,Item-0" meetingbar_alias \
	--set meetingbar_alias \
	alias.color="$WHITE" \
	icon="" \
	background.padding_left=0 \
	background.padding_right=-20 \
	label.drawing=off \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	icon.padding_right=-3 \
	background.color="$BAR_COLOR" \
	background.height=24 \
	background.corner_radius="$CORNER_RADIUS" \
	background.border_width="$BORDER_WIDTH" \
	background.border_color="$COLOR" \
	background.drawing=on
