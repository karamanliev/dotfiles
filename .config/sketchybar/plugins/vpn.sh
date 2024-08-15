#!/bin/bash

VPN=$(scutil --nc list | grep Connected | sed -E 's/.*"(.*)".*/\1/')

if [[ $VPN != "" ]]; then
	sketchybar --set "$NAME" \
		icon="󰖂" \
		label="Up" \
		click_script="networksetup -disconnectpppoeservice 'Despark VPN'"
else
	sketchybar --set "$NAME" \
		icon="󰖂" \
		label="Down" \
		click_script="networksetup -connectpppoeservice 'Despark VPN'"
fi
