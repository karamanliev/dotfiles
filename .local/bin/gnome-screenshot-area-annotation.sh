#!/bin/bash
source gnome-screenshot-area.sh
if [ -f $tmp_file ]; then
    satty -f $tmp_file
fi
