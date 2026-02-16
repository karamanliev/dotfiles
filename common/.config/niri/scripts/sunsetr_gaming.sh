#!/usr/bin/env bash

GAMING_APP_IDS=(
  "^steam_app"
  "gamescope"
)

GAMING_TITLES=(
  # "gamescope"
)

declare -A gaming_windows

niri msg --json event-stream |
  jq -rc --unbuffered '.WindowOpenedOrChanged // .WindowClosed // empty' |
  while read -r event; do

    if jq -e '.window' <<<"$event" &>/dev/null; then
      # Window opened/changed
      id=$(jq -r '.window.id' <<<"$event")
      app_id=$(jq -r '.window.app_id // ""' <<<"$event")
      title=$(jq -r '.window.title // ""' <<<"$event")

      for pattern in "${GAMING_APP_IDS[@]}" "${GAMING_TITLES[@]}"; do
        if [[ "$app_id" =~ $pattern || "$title" =~ $pattern ]]; then
          [[ ${#gaming_windows[@]} -eq 0 ]] && sunsetr preset gaming
          gaming_windows["$id"]=1
          break
        fi
      done

    else
      # Window closed
      id=$(jq -r '.id' <<<"$event")
      if [[ -n "${gaming_windows[$id]}" ]]; then
        unset gaming_windows["$id"]
        [[ ${#gaming_windows[@]} -eq 0 ]] && sunsetr preset default
      fi
    fi
  done
