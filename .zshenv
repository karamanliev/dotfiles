export IS_MACOS=$(uname | grep -q "Darwin" && echo true || echo false)

# set correct locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# set xdg paths
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export DOTFILES=$HOME/dotfiles

# set custom zsh config path
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# add scripts to path
PATH=$HOME/.local/bin:$PATH

if $IS_MACOS; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi
