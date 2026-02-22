#!/bin/bash
# Listens to sunsetr IPC events and syncs GTK color-scheme.
# Start this as a background daemon (e.g. from niri autostart).

SOCKET="${XDG_RUNTIME_DIR}/sunsetr-events.sock"
LAST_APPLIED_PERIOD=""

set_gtk_theme() {
  local period="$1"

  [ "$period" = "$LAST_APPLIED_PERIOD" ] && return

  case "$period" in
  day | sunset)
    LAST_APPLIED_PERIOD="$period"
    niri msg action do-screen-transition --delay-ms 350 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    zsh-sync-colors.sh catppuccin-latte
    ;;
  night | sunrise)
    LAST_APPLIED_PERIOD="$period"
    niri msg action do-screen-transition --delay-ms 350 2>/dev/null
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    zsh-sync-colors.sh tokyonight-moon
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

# Wait for waybar to be running and fully initialized before sending any signals
while ! pgrep waybar >/dev/null; do sleep 0.5; done
sleep 2

# Wait for sunsetr socket to be ready
while ! [ -S "$SOCKET" ]; do sleep 0.5; done

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
    done < <(socat -u UNIX-CONNECT:"$SOCKET" - 2>/dev/null)
  fi
  sleep 2
  sync_current
done
