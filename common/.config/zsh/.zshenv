# set correct locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# set xdg paths
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export DOTFILES=$HOME/dotfiles

# Check for secret envs and source them
if [[ -f "$DOTFILES/.env" ]]; then
  set -a
  source "$DOTFILES/.env"
  set +a
fi

# set custom zsh config path
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# skip ubuntu global compinit (handled by zsh-autocomplete)
[[ -f /etc/os-release ]] && grep -q '^ID=ubuntu' /etc/os-release && skip_global_compinit=1

# load nix bin paths and completions
[[ -f $ZDOTDIR/zsh-nix ]] && source $ZDOTDIR/zsh-nix

# add local and npm-global scripts to path
# mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global to set npm prefix
PATH=$HOME/.local/bin:$HOME/.npm-global/bin:$PATH
