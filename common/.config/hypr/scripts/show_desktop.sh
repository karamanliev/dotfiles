#!/bin/sh
get_opacity() {
  hyprctl getoption decoration:$1 | awk 'NR==1{print $2}'
}

set_opacity() {
  hyprctl --batch "\
    keyword decoration:active_opacity $1;\
    keyword decoration:inactive_opacity $1"
  exit
}

if [ "$(get_opacity active_opacity)" = "1.000000" ] && [ "$(get_opacity inactive_opacity)" = "1.000000" ]; then
  set_opacity 0
else
  set_opacity 1
fi
