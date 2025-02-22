#!/bin/bash
state=$(nmcli connection show Despark | grep -oE '[0-9]+ - (VPN connecting|VPN connected)')

if echo "$state" | grep -qi 'connecting'; then
  echo "󰴽  Connecting..."
elif echo "$state" | grep -qi 'connected'; then
  echo "  ON"
else
  echo "  OFF"
fi
