# Stop CTRL+S from sleeping the terminal and search instead
stty -ixon

export EDITOR="nvim"
export VISUAL="nvim"

export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000

# History options
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY

# Other
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NOMATCH
setopt NOTIFY
unsetopt beep

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[6 q"
}
zle -N zle-line-init
echo -ne '\e[6 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[6 q' ;} # Use beam shape cursor for each new prompt.

# Start the tmux session if not alraedy in the tmux session
if [[ ! -n $TMUX  ]]; then
  # Get the session IDs
  session_ids="$(tmux list-sessions)"

  # Create new session if no sessions exist
  if [[ -z "$session_ids" ]]; then
    tmux new-session
  fi

  # Select from following choices
  #   - Attach existing session
  #   - Create new session
  #   - Start without tmux
  create_new_session="Create new session"
  start_without_tmux="Start without tmux"
  choices="$session_ids\n${create_new_session}:\n${start_without_tmux}:"
  choice="$(echo $choices | fzf | cut -d: -f1)"

  if expr "$choice" : "[0-9]*$" >&/dev/null; then
    # Attach existing session
    tmux attach-session -t "$choice"
  elif [[ "$choice" = "${create_new_session}" ]]; then
    # Create new session
    tmux new-session
  elif [[ "$choice" = "${start_without_tmux}" ]]; then
    # Start without tmux
    :
  fi
fi

export ZSH_PLUGINS_FOLDER=/usr/share/zsh/plugins
source $ZSH_PLUGINS_FOLDER/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $ZSH_PLUGINS_FOLDER/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZSH_PLUGINS_FOLDER/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# omz plugins initialize
export OMZ="$HOME/.config/zsh/omz"
source $OMZ/lib/theme-and-appearance.zsh
source $OMZ/plugins/colored-man-pages/colored-man-pages.plugin.zsh

# Open man pages with nvim
# export MANPAGER='nvim +Man!'

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(fzf --zsh)"

export FZF_DEFAULT_OPTS="--height 60% --border --preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(hidden|)'"

# Accept the autosuggestion with ctrl + spacebar
bindkey '^ ' autosuggest-accept

# ALIASES

## General
alias c='clear'
alias h='history'

## GIT
alias ff='git pull --ff-only'
alias gs='git status'
alias gco='git checkout'

# eza
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'
alias ld='eza --icons --color=always -lD'
alias lf='eza -lfa --icons --color=always | grep -v /'

#show tree view of current directory - if no argument is passed, show 2 levels
alias lt='f() { if [ $# -eq 0 ]; then eza --tree --level=2 --icons --color=always --group-directories-first; else eza --tree --level="$1" --icons --color=always --group-directories-first; fi }; f'

# Remap
alias cat='bat'
alias top='btop'
alias v='nvim'
alias vim='nvim'

# pacman
alias pmuinfo='sudo pacman -Sy;pacman -Qu | cut -d " " -f 1 | fzf --multi --height 80% --reverse --preview "pacman -Qi {1}" | xargs -ro sudo pacman -S'

# Misc
alias reboot-win='sudo efibootmgr --bootnext 0003 && reboot'
