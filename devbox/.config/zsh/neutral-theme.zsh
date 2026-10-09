# Stowing devbox enables terminal-owned colors instead of desktop theme state.
zmodload zsh/datetime
typeset -g TERMINAL_THEME_OVERRIDE="${TERMINAL_THEME_OVERRIDE:-auto}"
typeset -g TERMINAL_THEME_NEXT_QUERY="${TERMINAL_THEME_NEXT_QUERY:-0}"
typeset -g TERMINAL_THEME_MODE="${TERMINAL_THEME_MODE:-dark}"

# Remove our own inherited settings, retaining unrelated user overrides.
terminal_theme_baseline() {
  local feature parameter key prefix=''
  local features="${DELTA_FEATURES:-+}"
  local -a retained_features retained_parameters
  [[ "$features" == +* ]] && prefix=+
  features="${features#+}"
  for feature in ${=features}; do
    [[ "$feature" == terminal-light || "$feature" == terminal-dark ]] && continue
    retained_features+=("$feature")
  done
  typeset -g TERMINAL_THEME_BASE_DELTA_FEATURES="$prefix${(j: :)retained_features}"
  for parameter in ${(z)GIT_CONFIG_PARAMETERS}; do
    key="${(Q)parameter}"
    case "${key%%=*}" in
      delta.light|delta.dark|delta.minus-style|delta.plus-style|delta.minus-emph-style|delta.plus-emph-style) continue ;;
    esac
    retained_parameters+=("$parameter")
  done
  typeset -g TERMINAL_THEME_BASE_GIT_PARAMETERS="${(j: :)retained_parameters}"
}

terminal_theme_receive() {
  emulate -L zsh
  # ZLE dispatches this widget only for an OSC 11 response prefix. Ordinary
  # keyboard input stays with the editor, even while a query is outstanding.
  local character response='' payload
  local pattern='^rgb:([[:xdigit:]]{1,4})/([[:xdigit:]]{1,4})/([[:xdigit:]]{1,4})$'
  local -a match mbegin mend weights=(0.2126 0.7152 0.0722)
  local -F deadline remaining brightness=0
  local -i index

  deadline=$(( EPOCHREALTIME + 0.3 ))
  while (( EPOCHREALTIME < deadline && ${#response} < 128 )); do
    remaining=$(( deadline - EPOCHREALTIME ))
    (( remaining > 0 )) || return 1
    builtin read -rsk 1 -t "$remaining" character || return 1
    response+="$character"
    [[ "$character" == $'\a' || "$response" == *$'\e\\' ]] && break
  done
  [[ "$response" == *$'\a' || "$response" == *$'\e\\' ]] || return 1
  payload="$response"
  payload="${payload%$'\a'}"
  payload="${payload%$'\e\\'}"
  [[ "$payload" =~ "$pattern" ]] || return 1
  for index in 1 2 3; do
    (( brightness += (16#${match[index]}) * weights[index] / (16.0 ** ${#match[index]} - 1) ))
  done
  # Keep consuming late replies and replies after a manual override so they never
  # become command-line text. Only automatic mode applies their colors.
  if [[ "$TERMINAL_THEME_OVERRIDE" == auto ]]; then
    if (( brightness > 0.5 )); then
      TERMINAL_THEME_MODE=light
    else
      TERMINAL_THEME_MODE=dark
    fi
    terminal_theme_apply
  fi
  return 0
}

terminal_theme_init_colors() {
  [[ "${TERMINAL_THEME_COLORS_INITIALIZED:-0}" == 1 ]] && return 0
  local colors
  if (( $+commands[vivid] )) && colors="$(vivid generate ansi 2>/dev/null)" && [[ -n "$colors" ]]; then
    export LS_COLORS="$colors"
  else
    # Keep basic ANSI colors when vivid is unavailable or cannot generate them.
    export LS_COLORS='di=34:ln=36:ex=32:pi=33:so=35:bd=33:cd=33:or=31:mi=31:su=31:sg=33:tw=34:ow=34:st=34'
  fi
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  typeset -g TERMINAL_THEME_COLORS_INITIALIZED=1
}

terminal_theme_apply() {
  export BAT_THEME=ansi
  export DELTA_FEATURES="${TERMINAL_THEME_BASE_DELTA_FEATURES:-+}"
  local light dark minus plus minus_emph plus_emph
  case "$TERMINAL_THEME_MODE" in
    light)
      export COLORFGBG='0;15'
      light=true dark=false
      minus='#f5e9e9' plus='#eaf2e6'
      minus_emph='#e8c6c6' plus_emph='#c9dfbe'
      ;;
    dark)
      export COLORFGBG='15;0'
      light=false dark=true
      minus='#393333' plus='#333933'
      minus_emph='#634141' plus_emph='#416341'
      ;;
  esac
  # Delta honors GIT_CONFIG_PARAMETERS above file/main-section settings.
  # Keep the dark colors in sync with local.conf's standalone defaults.
  export GIT_CONFIG_PARAMETERS="${TERMINAL_THEME_BASE_GIT_PARAMETERS:+$TERMINAL_THEME_BASE_GIT_PARAMETERS }'delta.light=$light' 'delta.dark=$dark' 'delta.minus-style=syntax $minus' 'delta.plus-style=syntax $plus' 'delta.minus-emph-style=syntax bold $minus_emph' 'delta.plus-emph-style=syntax bold $plus_emph'"
}

terminal_theme_refresh() {
  [[ "$TERMINAL_THEME_OVERRIDE" == auto ]] || return 0
  (( EPOCHREALTIME >= TERMINAL_THEME_NEXT_QUERY )) || return 0
  # Check at the first prompt and at most once per minute of activity.
  # Unsupported clients keep the last mode and use the same retry interval.
  TERMINAL_THEME_NEXT_QUERY=$(( EPOCHREALTIME + 60 ))
  # Do not wait for the reply. The permanent response widget also catches
  # delayed replies on later prompts without swallowing typed commands.
  { builtin print -rn $'\e]11;?\a' > /dev/tty } 2>/dev/null
  return 0
}

terminal-theme() {
  case "${1:-auto}" in
    light|dark)
      TERMINAL_THEME_OVERRIDE="$1"
      TERMINAL_THEME_MODE="$1"
      terminal_theme_apply
      ;;
    auto)
      TERMINAL_THEME_OVERRIDE=auto
      TERMINAL_THEME_NEXT_QUERY=0
      print 'Terminal theme: auto (refreshing at the next prompt)'
      return 0
      ;;
    *) print -u2 'Usage: terminal-theme [auto|light|dark]'; return 1 ;;
  esac
  print "Terminal theme: $TERMINAL_THEME_MODE ($TERMINAL_THEME_OVERRIDE)"
}

terminal_theme_baseline
terminal_theme_init_colors
terminal_theme_apply
zle -N terminal-theme-response terminal_theme_receive
for terminal_theme_keymap in emacs viins vicmd viopp visual isearch command; do
  bindkey -M "$terminal_theme_keymap" $'\e]11;' terminal-theme-response
done
unset terminal_theme_keymap
autoload -Uz add-zsh-hook
add-zsh-hook -d precmd terminal_theme_refresh
add-zsh-hook -d preexec terminal_theme_refresh
autoload -Uz add-zle-hook-widget
add-zle-hook-widget -d line-init terminal_theme_refresh
# The first prompt queries at startup; later prompts check the one-minute gate.
# Querying here avoids changing terminal modes before commands.
add-zle-hook-widget line-init terminal_theme_refresh
