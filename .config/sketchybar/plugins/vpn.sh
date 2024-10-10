#!/bin/bash

get_vpn_status() {
	local status=$(scutil --nc list | grep "Despark VPN" | awk '{gsub(/[()]/, "", $2); print $2}')
	echo "$status"
}

case "$(get_vpn_status)" in
"Connected")
	sketchybar --set "$NAME" \
		icon="󰒍" \
		label="Up" \
		click_script="networksetup -disconnectpppoeservice 'Despark VPN'"
	;;
"Connecting")
	sketchybar --set "$NAME" \
		icon="󱂇" \
		label="Connecting..." \
		click_script="networksetup -disconnectpppoeservice 'Despark VPN'"
	;;
*)
	sketchybar --set "$NAME" \
		icon="󰒎" \
		label="Down" \
		click_script="networksetup -connectpppoeservice 'Despark VPN'"
	;;
esac
