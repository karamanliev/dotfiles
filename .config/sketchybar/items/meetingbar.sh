#!/bin/bash

COLOR="$MAGENTA"

sketchybar --add alias "MeetingBar,Item-0" e \
	--rename "MeetingBar,Item-0" meetingbar_alias \
	--set meetingbar_alias \
	update_freq=180 \
	alias.color="$WHITE" \
	icon="" \
	label.drawing=off \
	icon.color="$WHITE" \
	icon.padding_left=10 \
	icon.padding_right=3 \
	script="$PLUGIN_DIR/meetingbar.sh" \
	click_script="osascript $MAIN_DIR/open_meetingbar.applescript" \
	--subscribe meetingbar_alias system_woke
