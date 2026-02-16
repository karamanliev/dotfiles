#!/bin/bash

handle_event() {
  local event_json="$1"

  # Check if this is a WindowOpenedOrChanged event
  if echo "$event_json" | jq -e '.WindowOpenedOrChanged' > /dev/null 2>&1; then
    # Extract window information
    local window_title=$(echo "$event_json" | jq -r '.WindowOpenedOrChanged.title')
    local window_id=$(echo "$event_json" | jq -r '.WindowOpenedOrChanged.id')

    # Check if this is a Picture-in-Picture window
    if [ "$window_title" = "Picture-in-Picture" ]; then
      # Move to floating layout and position it in the bottom-right corner
      niri msg action set-window-floating --window-id "$window_id" --floating true

      # Set size and position (equivalent to the floating state in original script)
      # 640x360 size, positioned at bottom-right corner
      niri msg action resize-window --window-id "$window_id" --width 640 --height 360
      niri msg action move-window --window-id "$window_id" --x 20 --y 1060
    fi
  fi
}

# Connect to niri IPC and process events
niri msg --json event-stream | while read -r line; do
  handle_event "$line"
done