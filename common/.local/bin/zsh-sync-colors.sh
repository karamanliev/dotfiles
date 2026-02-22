#!/bin/bash

colors=$(ls ~/.config/kitty/themes | sed 's/.conf//')

get_tmux_color() {
  local color_type=$1
  local color=$(nvim --headless -c "redir => output | echo nvim_get_hl_by_name('StatusLine', v:true)['$color_type'] | redir END | echo output | quit" 2>&1)

  color=$(echo "$color" | head -n1 | sed 's/[^0-9]*//g')

  printf "#%06x" "$color"
}

apply_nvim_theme() {
  local theme="$1"

  for sock in /tmp/nvim*; do
    [ -S "$sock" ] || continue
    nvim --server "$sock" --remote-send "<cmd>highlight clear<CR><cmd>colorscheme ${theme}<CR>" 2>/dev/null
  done
}

set_delta_theme() {
  local color_scheme="$1"
  local dir="$HOME/.config/git"

  case "$color_scheme" in
  rose-pine-dawn | tokyonight-day | catppuccin-latte)
    ln -sf "$dir/delta-light.conf" "$dir/delta.conf"
    ;;
  *)
    ln -sf "$dir/delta-dark.conf" "$dir/delta.conf"
    ;;
  esac
}

set_colorscheme() {
  local color_scheme=$1
  sed -i "s/vim.cmd.colorscheme('\(.*\)')/vim.cmd.colorscheme('$color_scheme')/" ~/.config/nvim/lua/custom/colorscheme.lua

  # apply to running nvim instances
  apply_nvim_theme "$color_scheme"

  # delta colors (git picks this up next run)
  set_delta_theme "$color_scheme"

  # change tmux colors after nvim colorscheme change
  bg_color_hex=$(get_tmux_color "background")
  fg_color_hex=$(get_tmux_color "foreground")

  sed -i "s/^bg_color=.*/bg_color=$bg_color_hex/" ~/.config/tmux/dynamic_colors.conf
  sed -i "s/^fg_color=.*/fg_color=$fg_color_hex/" ~/.config/tmux/dynamic_colors.conf

  tmux source-file ~/.config/tmux/tmux.conf
}

# direct mode
if [[ -n "$1" ]]; then
  set_colorscheme "$1"
  kitten themes --reload-in=all "$1"
  exit 0
fi

# fzf mode
echo "$colors" | fzf \
  --prompt "Colorscheme: " \
  --layout=reverse \
  --preview "kitten themes --reload-in=all {}" \
  --preview-window right:70%:wrap:nohidden \
  --exit-0 --expect=ctrl-q,ctrl-c,esc | {
  read -r key
  read -r selection
  if [[ -n "$key" ]]; then
    current_theme=$(grep 'vim.cmd.colorscheme' ~/.config/nvim/lua/custom/colorscheme.lua | sed -n "s/.*'\\(.*\\)'.*/\\1/p")
    kitten themes --reload-in=all "$current_theme"
  elif [[ -n "$selection" ]]; then
    set_colorscheme "$selection"
    kitten themes --reload-in=all "$selection"
  fi
}
