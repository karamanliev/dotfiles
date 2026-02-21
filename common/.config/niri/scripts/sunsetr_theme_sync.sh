#!/bin/bash
# Listens to sunsetr IPC events and syncs GTK color-scheme.
# Start this as a background daemon (e.g. from niri autostart).

SOCKET="${XDG_RUNTIME_DIR}/sunsetr-events.sock"

set_gtk_theme() {
  local period="$1"
  case "$period" in
  day | sunset)
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    ;;
  night | sunrise)
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    ;;
  esac
}

# Sync theme to current sunsetr state on startup / reconnect
sync_current() {
  local status period
  status=$(sunsetr status --json 2>/dev/null) || return
  period=$(echo "$status" | jq -r '.period // empty')
  set_gtk_theme "$period"
  pkill -RTMIN+2 waybar
}

sync_current

# Listen for IPC events, resync and reconnect on disconnect
while true; do
  if [ -S "$SOCKET" ]; then
    while read -r line; do
      [ -z "$line" ] && continue

      event_type=$(echo "$line" | jq -r '.event_type // empty' 2>/dev/null)
      case "$event_type" in
      period_changed)
        period=$(echo "$line" | jq -r '.to_period // empty')
        set_gtk_theme "$period"
        pkill -RTMIN+2 waybar
        ;;
      preset_changed)
        to_preset=$(echo "$line" | jq -r '.to_preset // empty')
        if [ -n "$to_preset" ]; then
          # Switching to a named preset
          case "$to_preset" in
          day | gaming) set_gtk_theme "day" ;;
          night) set_gtk_theme "night" ;;
          esac
        else
          # Switching back to default (to_preset is null) — use target_period
          target_period=$(echo "$line" | jq -r '.target_period // empty')
          set_gtk_theme "$target_period"
        fi
        pkill -RTMIN+2 waybar
        ;;
      esac
    done < <(socat UNIX-CONNECT:"$SOCKET" - 2>/dev/null)
  fi
  # Resync after disconnect to catch any missed events
  sleep 2
  sync_current
done
