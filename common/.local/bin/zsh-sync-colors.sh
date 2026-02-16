#!/bin/bash

colors=$(ls ~/.config/kitty/themes | sed 's/.conf//')
get_tmux_color() {
  local color_type=$1
  local color=$(nvim --headless -c "redir => output | echo nvim_get_hl_by_name('StatusLine', v:true)['$color_type'] | redir END | echo output | quit" 2>&1)

  color=$(echo "$color" | head -n1 | sed 's/[^0-9]*//g')

  printf "#%06x" "$color"
}

echo "$colors" | fzf \
  --prompt "Colorscheme: " \
  --layout=reverse \
  --preview "kitten themes --reload-in=all {}" \
  --preview-window right:70%:wrap:nohidden \
  --exit-0 --expect=ctrl-q,ctrl-c,esc | {
  read -r key
  read -r selection
  if [[ -n "$key" ]]; then
    current_theme=$(cat ~/.config/nvim/lua/custom/colorscheme.lua | grep 'vim.cmd.colorscheme' | sed -n "s/.*'\\(.*\\)'.*/\\1/p")
    # kitty @ --to unix:/tmp/kitty_remote_control set-colors ~/.config/kitty/themes/"$current_theme".conf
    kitten themes --reload-in=all $current_theme
  elif [[ -n "$selection" ]]; then
    sed -i "s/vim.cmd.colorscheme('\(.*\)')/vim.cmd.colorscheme('$selection')/" ~/.config/nvim/lua/custom/colorscheme.lua

    # change tmux colors after nvim colorscheme change
    bg_color_hex=$(get_tmux_color "background")
    fg_color_hex=$(get_tmux_color "foreground")

    sed -i "s/^bg_color=.*/bg_color=$bg_color_hex/" ~/.config/tmux/dynamic_colors.conf
    sed -i "s/^fg_color=.*/fg_color=$fg_color_hex/" ~/.config/tmux/dynamic_colors.conf

    tmux source-file ~/.config/tmux/tmux.conf
  fi
}
