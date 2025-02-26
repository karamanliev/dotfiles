#!/bin/bash

if hyprctl clients | grep -qi "1Password"; then
  hyprctl dispatch closewindow class:1Password
else
  1password
fi
