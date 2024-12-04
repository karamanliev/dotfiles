#!/usr/bin/env bash

COLOR="$CYAN"

get_vpn_info() {
	local status=$(scutil --nc list | grep "Despark VPN" | awk '{gsub(/[()]/, "", $2); print $2}')

	case "$status" in
	"Connected")
		echo "󰒍|Up"
		;;
	"Disconnected")
		echo "󰒎|Down"
		;;
	*)
		echo "󱂇|Connecting..."
		;;
	esac
}

vpn_info=$(get_vpn_info)
icon=$(echo "$vpn_info" | cut -d'|' -f1)
label=$(echo "$vpn_info" | cut -d'|' -f2)

sketchybar --add item vpn q \
	--set vpn \
	update_freq=120 \
	label.color="$WHITE" \
	icon.color="$WHITE" \
	icon.padding_left=8 \
	label.padding_right=0 \
	icon="$icon" \
	label="$label" \
	click_script="$PLUGIN_DIR/vpn.sh"
