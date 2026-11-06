(( $+commands[vivid] )) || return 0

_noctalia_vivid_refresh() {
  local theme=~/.config/vivid/themes/noctalia.yml
  local content colors
  [[ -r "$theme" ]] || return 0
  content=$(< "$theme")
  [[ "$content" == "${_noctalia_vivid_content-}" ]] && return 0

  colors=$(vivid generate "$theme") || return
  export LS_COLORS="$colors"
  zstyle ':completion:*:default' list-colors ${(s.:.)colors}
  typeset -g _noctalia_vivid_content="$content"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _noctalia_vivid_refresh
_noctalia_vivid_refresh
