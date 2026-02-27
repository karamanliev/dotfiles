#!/usr/bin/env bash
set -euo pipefail

# If we're inside tmux and not already in the inhibit window,
# open a new window and run this script inside it.
if [ -n "${TMUX:-}" ] && [ -z "${SSH_INHIBIT_WINDOW:-}" ]; then
  tmux new-window -n "#[fg=#e64553,bold]SSH INHIBIT#[default]" \
    "SSH_INHIBIT_WINDOW=1 $0"
  exit 0
fi

echo "Suspend disabled while any SSH session is active... (Ctrl+C to stop)"

touch /tmp/no-suspend

cleanup() {
  echo
  echo "Re-enabling suspend."
  rm -f /tmp/no-suspend

  # Force swayidle to immediately enter idle state
  pkill -USR1 -x swayidle 2>/dev/null || true
}
trap cleanup INT TERM EXIT

while who | grep -q 'pts/'; do
  sleep 5
done

echo "No SSH sessions detected — suspend re-enabled."
