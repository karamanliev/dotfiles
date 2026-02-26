#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"

case "$MODE" in
light | dark) ;;
*) exit 0 ;;
esac

tries=0
while ! pgrep -x waybar >/dev/null 2>&1; do
  tries=$((tries + 1))
  [[ "$tries" -ge 10 ]] && exit 0
  sleep 0.5
done

sleep 0.5
pkill -RTMIN+2 waybar >/dev/null 2>&1 || true
