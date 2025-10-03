#!/bin/bash

# Check if display argument is provided
DISPLAY_NAME="${1:-DP-1}"

# Define menu options and pipe to dmenu
selected=$(
  cat <<EOF | vicinae dmenu -p "Search recording modes for [$DISPLAY_NAME]:" -n "[$DISPLAY_NAME]" -s "Choose mode:"
⏺️ Toggle Recording
⏯️ Pause/Resume Recording
🔄 Toggle Replay
💾 Save Replay
EOF
)

# Execute command based on selection
case "$selected" in
"⏺️ Toggle Recording")
  "$HOME/.local/bin/gsr.sh" toggle-recording "$DISPLAY_NAME"
  ;;
"⏯️ Pause/Resume Recording")
  "$HOME/.local/bin/gsr.sh" pause "$DISPLAY_NAME"
  ;;
"🔄 Toggle Replay")
  "$HOME/.local/bin/gsr.sh" toggle-replay "$DISPLAY_NAME"
  ;;
"💾 Save Replay")
  "$HOME/.local/bin/gsr.sh" save-replay "$DISPLAY_NAME"
  ;;
esac
