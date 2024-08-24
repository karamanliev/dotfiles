if hyprctl layers | grep -qi "rofi"; then pkill "rofi"; else rofi -show $1; fi
