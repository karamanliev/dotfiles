#!/bin/bash

# Get the current value of workspaces-only-on-primary
current_value=$(gsettings get org.gnome.mutter workspaces-only-on-primary)

# Toggle the value
if [ "$current_value" == "true" ]; then
	gsettings set org.gnome.mutter workspaces-only-on-primary false
	notify-send -a "Workspaces" -i dialog-information "Workspaces are working on all displays now."
else
	gsettings set org.gnome.mutter workspaces-only-on-primary true
	notify-send -a "Workspaces" -i dialog-information "Workspaces are working only on primary display now."
fi
