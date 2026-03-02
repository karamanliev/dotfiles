#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
THEME_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/darkman/themes.conf"
CLAUDE_CONFIG="$HOME/.claude.json"
CODEX_CONFIG="$HOME/.codex/config.toml"

source "$THEME_CONFIG"

case "$MODE" in
light)
  CLAUDE_THEME="light"
  CODEX_THEME="$LIGHT_THEME"
  ;;
dark)
  CLAUDE_THEME="dark"
  CODEX_THEME="$DARK_THEME"
  ;;
*) exit 0 ;;
esac

[[ -f "$CLAUDE_CONFIG" ]] &&
  if command -v jq &>/dev/null; then
    jq --arg theme "$CLAUDE_THEME" '. + {theme: $theme}' "$CLAUDE_CONFIG" >"$CLAUDE_CONFIG.tmp" &&
      mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
    echo "Claude Code switched to $CLAUDE_THEME mode"
  fi

[[ -f "$CODEX_CONFIG" ]] &&
  sed -Ei '/^\[tui\]/,/^\[/{s/^(theme[[:space:]]*=[[:space:]]*")[^"]*(")$/\1'"$CODEX_THEME"'\2/}' "$CODEX_CONFIG"
