#!/usr/bin/env bash

set -euo pipefail

declare -A handled

handle_pip_window() {
  local id="$1"
  local position=""

  if [[ -n "${handled[$id]:-}" ]]; then
    return
  fi

  handled[$id]=1

  for _ in 1 2 3 4 5; do
    position=$(niri msg -j windows | jq -r --argjson id "$id" '
      .[]
      | select(.id == $id)
      | [.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1]]
      | @tsv
    ')

    if [[ -n "$position" ]]; then
      break
    fi

    sleep 0.05
  done

  if [[ -z "$position" ]]; then
    return
  fi

  read -r column row <<< "$position"

  if (( column > 1 && row == 1 )); then
    niri msg action consume-or-expel-window-left --id "$id"
    sleep 0.05
  fi

  niri msg action set-window-height --id "$id" "28%"
}

niri msg --json event-stream \
  | jq -rc --unbuffered '
      select(.WindowOpenedOrChanged)
      | .WindowOpenedOrChanged.window
      | select(.title == "Picture-in-Picture")
      | .id
    ' \
  | while read -r id; do
      handle_pip_window "$id"
    done
