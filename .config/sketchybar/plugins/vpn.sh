#!/bin/bash

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
	sketchybar --set "$NAME" icon="󰖂" \
		label="Up" \
		drawing=on
else
	sketchybar --set "$NAME" drawing=off
fi
