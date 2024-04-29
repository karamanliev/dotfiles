# Stop CTRL+S from sleeping the terminal and search instead
stty -ixon

export EDITOR="nvim"
export VISUAL="nvim"

export ZSH_MODULES=$HOME/.config/zsh

export HISTFILE=$ZSH_MODULES/.zsh-history
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

# Open man pages with nvim
export MANPAGER='nvim +Man!'

# Default fzf options
export FZF_DEFAULT_OPTS="--height 60% --border --preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(hidden|)'"

source $ZSH_MODULES/.zsh-vim-mode
source $ZSH_MODULES/.zsh-plugins
source $ZSH_MODULES/.zsh-tmux
source $ZSH_MODULES/.zsh-keys
source $ZSH_MODULES/.zsh-aliases
