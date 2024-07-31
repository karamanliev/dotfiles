#!/bin/bash
tmp_file=/tmp/gnome-screenshot-area
env GDK_BACKEND=x11 gnome-screenshot -acf $tmp_file
