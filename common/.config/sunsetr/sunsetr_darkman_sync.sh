#!/usr/bin/env bash
set -euo pipefail

SOCKET="${XDG_RUNTIME_DIR}/sunsetr-events.sock"
LAST_MODE=""

period_to_mode() {
  case "${1:-}" in
  day | sunset) echo "light" ;;
  night | sunrise) echo "dark" ;;
  *) return 1 ;;
  esac
}

apply_mode() {
  local mode="${1:-}"
  [[ "$mode" == "light" || "$mode" == "dark" ]] || return
  [[ "$mode" == "$LAST_MODE" ]] && return

  darkman set "$mode" >/dev/null 2>&1 || return
  LAST_MODE="$mode"
}

sync_current() {
  local status preset period mode

  status="$(sunsetr status --json 2>/dev/null)" || return
  preset="$(jq -r '.active_preset // "default"' <<<"$status")"

  case "$preset" in
  day | gaming)
    mode="light"
    ;;
  night)
    mode="dark"
    ;;
  *)
    period="$(jq -r '.period // empty' <<<"$status")"
    mode="$(period_to_mode "$period" || true)"
    ;;
  esac

  [[ -n "${mode:-}" ]] && apply_mode "$mode"
}

until [[ -S "$SOCKET" ]]; do sleep 0.5; done
sync_current

while true; do
  if [[ -S "$SOCKET" ]]; then
    while read -r line; do
      [[ -z "$line" ]] && continue

      event_type="$(jq -r '.event_type // empty' <<<"$line" 2>/dev/null)"
      case "$event_type" in
      period_changed)
        mode="$(period_to_mode "$(jq -r '.to_period // empty' <<<"$line")" || true)"
        [[ -n "${mode:-}" ]] && apply_mode "$mode"
        ;;
      preset_changed)
        to_preset="$(jq -r '.to_preset // empty' <<<"$line")"
        if [[ -n "$to_preset" ]]; then
          case "$to_preset" in
          day | gaming) apply_mode "light" ;;
          night) apply_mode "dark" ;;
          esac
        else
          target_period="$(jq -r '.target_period // empty' <<<"$line")"
          mode="$(period_to_mode "$target_period" || true)"
          [[ -n "${mode:-}" ]] && apply_mode "$mode"
        fi
        ;;
      esac
    done < <(socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null)
  fi

  sleep 2
  sync_current
done
