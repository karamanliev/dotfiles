#!/bin/bash

COLOR="$WHITE"

sketchybar --add alias "TextInputMenuAgent,Item-0" right \
	--add event input_change "AppleSelectedInputSourcesChangedNitification" \
	--rename "TextInputMenuAgent,Item-0" input_alias \
	--set input_alias alias.color="$COLOR" \
	input_alias background.padding_left=-6 \
	set input_alias background.padding_right=-13 \
	click_script="osascript $MAIN_DIR/switch_input_source.applescript" \
	--subscribe input_alias input_change system_woke
