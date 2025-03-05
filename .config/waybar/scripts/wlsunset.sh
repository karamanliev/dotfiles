if pgrep wlsunset >/dev/null 2>&1; then
  killall -9 wlsunset >/dev/null 2>&1
  ddcutil --noverify --bus 1 setvcp 10 100 &
  ddcutil --noverify --bus 4 setvcp 10 100 &
else
  longitude="27.910543"
  latitude="43.204666"
  wlsunset -l $latitude -L $longitude >/dev/null 2>&1 &
  ddcutil --noverify --bus 1 setvcp 10 75 &
  ddcutil --noverify --bus 4 setvcp 10 75 &
fi
pkill -35 waybar
