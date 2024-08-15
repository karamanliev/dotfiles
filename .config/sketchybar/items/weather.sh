#!/bin/bash

COLOR="$WHITE"

sketchybar --add alias "Raycast,extension_weather_menubar__c460fc92-202d-49bf-b9c4-e486b58a0189" right \
	--rename "Raycast,extension_weather_menubar__c460fc92-202d-49bf-b9c4-e486b58a0189" weather_alias \
	--set weather_alias alias.color="$COLOR" \
	input_alias background.padding_left=-6 \
	input_alias background.padding_right=-13
