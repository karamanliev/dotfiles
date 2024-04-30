export IS_MACOS=$(uname | grep -q "Darwin" && echo true || echo false)

if $IS_MACOS; then
	eval "$(/opt/homebrew/bin/brew shellenv)"

	# Check if Homebrew is installed
	if [ ! $(command -v brew) ]; then
		echo "Homebrew is not installed. Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
fi

# set correct locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export DOTFILES=$HOME/dotfiles
