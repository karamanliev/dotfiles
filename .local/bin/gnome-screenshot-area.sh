#!/bin/bash
tmp_file=/tmp/gnome-screenshot-area.png
rm -rf $tmp_file
env GDK_BACKEND=x11 gnome-screenshot -acf $tmp_file
