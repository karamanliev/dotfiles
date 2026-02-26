#!/usr/bin/env bash
set -euo pipefail

command -v nvim >/dev/null 2>&1 || exit 0

get_tmux_color() {
  local color_type="$1"
  local color

  color="$(
    nvim --headless \
      -c "redir => output | echo nvim_get_hl(0, {'name': 'StatusLine', 'link': v:false})['$color_type'] | redir END | echo output | quit" \
      2>&1 | head -n1 | tr -cd '0-9'
  )"

  [[ -n "$color" ]] || return 1
  printf '#%06x' "$color"
}

BG_COLOR="$(get_tmux_color bg || true)"
FG_COLOR="$(get_tmux_color fg || true)"

[[ "$BG_COLOR" =~ ^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$ ]] || exit 0
[[ "$FG_COLOR" =~ ^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$ ]] || exit 0

TMUX_DYNAMIC_FILE="$HOME/.config/tmux/dynamic_colors.conf"
mkdir -p "$(dirname "$TMUX_DYNAMIC_FILE")"
printf 'bg_color=%s\nfg_color=%s\n' "$BG_COLOR" "$FG_COLOR" >"$TMUX_DYNAMIC_FILE"

if command -v tmux >/dev/null 2>&1; then
  tmux source-file "$HOME/.config/tmux/tmux.conf" >/dev/null 2>&1 || true
fi
