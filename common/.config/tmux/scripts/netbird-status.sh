#!/usr/bin/env sh

command -v netbird >/dev/null 2>&1 || exit 0

status_output="$(netbird status 2>/dev/null)"
[ -n "$status_output" ] || exit 0

printf '%s\n' "$status_output" | awk '
  /^Management:/ {
    if ($2 == "Connected") {
      connected = 1
    }
  }
  END {
    if (connected) {
      exit 0
    } else {
      exit 1
    }
  }
' || exit 0

printf '#[default]󰖂 #[fg=#{fg_color}]Up  '
