# Stop CTRL+S from sleeping the terminal and search instead
stty -ixon

export ZSH_MODULES=$XDG_CONFIG_HOME/zsh
source $ZSH_MODULES/zsh-env

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

# zsh-autocomplete fix
# https://github.com/marlonrichert/zsh-autocomplete/issues/761
setopt INTERACTIVE_COMMENTS

source $ZSH_MODULES/zsh-vim-mode
source $ZSH_MODULES/zsh-plugins
source $ZSH_MODULES/zsh-tmux
source $ZSH_MODULES/zsh-keys
source $ZSH_MODULES/zsh-aliases
source $ZSH_MODULES/zsh-functions

if $IS_MACOS; then
  source $ZSH_MODULES/zsh-macos-env
  source $ZSH_MODULES/zsh-macos-aliases
  source $ZSH_MODULES/zsh-macos-functions
fi
