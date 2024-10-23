#!/bin/bash

if $IS_MACOS; then
    sed() {
        gsed "$@"
    }
fi

# Function to get color and convert to hex
get_tmux_color() {
    local color_type=$1
    local color=$(nvim --headless -c "redir => output | echo nvim_get_hl_by_name('StatusLine', v:true)['$color_type'] | redir END | echo output | quit" 2>&1)

    color=$(echo "$color" | head -n1 | sed 's/[^0-9]*//g')

    printf "#%06x" "$color"
}

get_kitty_color() {
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
kitty_colorscheme=$(get_kitty_color $1)
echo "Kitty Colorscheme: $kitty_colorscheme"

kitty_themes_dir="$HOME/.config/kitty/themes"
if [ -f "$kitty_themes_dir/$kitty_colorscheme.conf" ]; then
    kitty_theme="$kitty_colorscheme.conf"
else
    echo "Theme $kitty_colorscheme.conf not found. Using default.conf"
    kitty_theme="default.conf"
fi

# Replace colors in tmux config
sed -i "s/^bg_color=.*/bg_color=$bg_color_hex/" ~/dotfiles/.config/tmux/dynamic_colors.conf
sed -i "s/^fg_color=.*/fg_color=$fg_color_hex/" ~/dotfiles/.config/tmux/dynamic_colors.conf
sed -i "s|^include themes/.*|include themes/$kitty_theme|" ~/dotfiles/.config/kitty/colorscheme.conf

# Reload tmux configuration
tmux source-file ~/dotfiles/.config/tmux/tmux.conf
# Reload kitty configuration
kitty @ load-config
