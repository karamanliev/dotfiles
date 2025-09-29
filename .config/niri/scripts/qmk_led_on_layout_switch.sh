#!/usr/bin/env bash
SCRIPT_PATH="/home/ico/.config/hypr/scripts/qmk_led_on_layout_switch.py"

function handle_event {
  # Parse the JSON event to extract keyboard layout information
  local event_json="$1"

  # Check if this is a KeyboardLayoutSwitched event
  if echo "$event_json" | jq -e '.KeyboardLayoutSwitched' > /dev/null 2>&1; then
    # Extract the layout index
    local layout_idx=$(echo "$event_json" | jq -r '.KeyboardLayoutSwitched.idx')

    # Get current keyboard layouts to map index to layout name
    local layouts_json=$(niri msg --json keyboard-layouts)

    if [ $? -eq 0 ]; then
      # Extract the layout name for the given index
      local layout_name=$(echo "$layouts_json" | jq -r --argjson idx "$layout_idx" '.names[$idx]')

      # Determine language based on layout name and call the Python script
      if echo "$layout_name" | grep -qi "english\|us\|en"; then
        python3 "$SCRIPT_PATH" en
      else
        python3 "$SCRIPT_PATH" bg
      fi
    fi
  fi
}

# Connect to niri IPC and process events
niri msg --json event-stream | while read -r line; do
  handle_event "$line"
done