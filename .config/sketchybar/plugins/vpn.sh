#!/bin/bash
get_vpn_status() {
	local status=$(scutil --nc list | grep "Despark VPN" | awk '{gsub(/[()]/, "", $2); print $2}')
	echo "$status"
}

case "$(get_vpn_status)" in
"Connected")
	networksetup -disconnectpppoeservice 'Despark VPN'

	sketchybar --set "$NAME" \
		icon="󰒎" \
		label="Down"
	;;
"Disconnected")
	networksetup -connectpppoeservice 'Despark VPN'

	while [[ "$(get_vpn_status)" == "Connecting" ]]; do
		sketchybar --set "$NAME" \
			icon="󱂇" \
			label="Connecting..."
		sleep 1
	done

	sketchybar --set "$NAME" \
		icon="󰒍" \
		label="Up"

	;;
"Connecting")
	networksetup -disconnectpppoeservice 'Despark VPN'

	while [[ "$(get_vpn_status)" == "Disconnecting" ]]; do
		sketchybar --set "$NAME" \
			icon="󰒎" \
			label="Disconnecting..."
		sleep 1
	done

	sketchybar --set "$NAME" \
		icon="󰒎" \
		label="Down"

	;;

*)
	echo "Unknown status"
	;;
esac
