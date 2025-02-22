#!/bin/bash

# Immediately refresh Waybar
pkill -RTMIN+3 waybar

# Toggle VPN connection
if nmcli connection show --active | grep -qi vpn; then
  nmcli connection down Despark
else
  nmcli connection up Despark
fi

# Refresh Waybar every second for 20 seconds
for i in {1..20}; do
  sleep 1
  pkill -RTMIN+3 waybar
done &
