export IS_MACOS

if [[ $(uname) == "Darwin" ]] && type brew &>/dev/null; then
	IS_MACOS=true
else
	IS_MACOS=false
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if $IS_MACOS; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export DOTFILES=$HOME/dotfiles
