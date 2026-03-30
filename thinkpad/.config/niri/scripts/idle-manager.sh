#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---watch}"
SCRIPT_PATH="$HOME/.config/niri/scripts/idle-manager.sh"
LOCK_FILE="/tmp/niri-idle-watch.lock"
FALLBACK_POLL_SECONDS="${NIRI_IDLE_POLL_SECONDS:-60}"

NIRI_BIN="$HOME/.nix-profile/bin/niri"

run_swayidle() {
  local suspend_timeout="$1"

  exec swayidle -w \
    timeout 120 "$NIRI_BIN msg action power-off-monitors" \
    timeout "$suspend_timeout" 'systemctl suspend'
}

case "$MODE" in
  --run-normal)
    run_swayidle 600 # 10 minutes
    ;;
  --run-extended)
    run_swayidle 3600 # 60 minutes
    ;;
  --watch)
    ;;
  *)
    echo "Usage: $0 [--watch|--run-normal|--run-extended]" >&2
    exit 2
    ;;
esac

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "Error: WAYLAND_DISPLAY is not set. Run this from the niri session." >&2
  exit 1
fi

exec 9>"$LOCK_FILE"
if command -v flock >/dev/null 2>&1; then
  if ! flock -n 9; then
    echo "Idle watcher is already running."
    exit 0
  fi
fi

has_ssh_session() {
  ss -Htn state established "( sport = :22 )" | grep -q .
}

wait_for_state_change() {
  if command -v inotifywait >/dev/null 2>&1 && [ -e /run/utmp ]; then
    inotifywait -q -e close_write,attrib,move_self,delete_self /run/utmp >/dev/null 2>&1 || sleep 1
  else
    sleep "$FALLBACK_POLL_SECONDS"
  fi
}

restart_swayidle() {
  local run_mode="$1"

  pkill -x swayidle 2>/dev/null || true
  nohup "$SCRIPT_PATH" "$run_mode" >/dev/null 2>&1 &

  sleep 0.2
  pgrep -x swayidle >/dev/null
}

normal_mode="--run-normal"
extended_mode="--run-extended"

cleanup() {
  restart_swayidle "--run-normal" || true
}
trap cleanup INT TERM EXIT

current_mode=""

while true; do
  if has_ssh_session; then
    desired_mode="$extended_mode"
  else
    desired_mode="$normal_mode"
  fi

  if [ "$desired_mode" != "$current_mode" ]; then
    if restart_swayidle "$desired_mode"; then
      current_mode="$desired_mode"
    else
      current_mode=""
    fi
  fi

  wait_for_state_change
done
