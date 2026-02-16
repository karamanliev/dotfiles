#!/bin/bash

# Function to get color and convert to hex
get_tmux_color() {
  local color_type=$1
  local color=$(nvim --headless -c "redir => output | echo nvim_get_hl_by_name('StatusLine', v:true)['$color_type'] | redir END | echo output | quit" 2>&1)

  color=$(echo "$color" | head -n1 | sed 's/[^0-9]*//g')

  printf "#%06x" "$color"
}

get_nvim_color() {
  local colorscheme

  if [ -n "$1" ]; then
    colorscheme="$1"
  else
    colorscheme=$(nvim --headless -c "redir => output | colo | redir END | echo output | quit" 2>&1)
  fi

  printf "$colorscheme" | head -n1 | sed 's/[^a-zA-Z0-9._-]//g'
}

# Get background color
bg_color_hex=$(get_tmux_color "background")
echo "BG Color: $bg_color_hex"

# Get foreground color
fg_color_hex=$(get_tmux_color "foreground")
echo "FG Color: $fg_color_hex"

# Get Kitty colorscheme
new_kitty_theme=$(get_nvim_color $1)
echo "Kitty Colorscheme: $new_kitty_theme"
kitty_theme="default"

kitty_themes_dir="$HOME/.config/kitty/themes"
if [ -f "$kitty_themes_dir/$new_kitty_theme.conf" ]; then
  kitty_theme="$new_kitty_theme"
else
  echo "Theme $new_kitty_theme.conf not found. Using default.conf"
  # kitty_theme="default"
fi

# Replace colors in tmux config
sed -i "s/^bg_color=.*/bg_color=$bg_color_hex/" ~/.config/tmux/dynamic_colors.conf
sed -i "s/^fg_color=.*/fg_color=$fg_color_hex/" ~/.config/tmux/dynamic_colors.conf
# sed -i "s|^include themes/.*|include themes/$kitty_theme|" ~/.config/kitty/colorscheme.conf

# Reload tmux configuration
tmux source-file ~/.config/tmux/tmux.conf
# Reload kitty configuration
kitten themes --reload-in=all $kitty_theme
