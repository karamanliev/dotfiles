#!/usr/bin/env bash
# Toggles local git ignore for files, which should be in the repo with
# default values, but I don't want to show up in git status.

# Files to toggle
FILES=(
  "common/.config/kitty/current-theme.conf"
  "common/.config/kitty/kitty.conf"
  "common/.config/nvim/lua/custom/colorscheme.lua"
  "common/.config/tmux/dynamic_colors.conf"
)

toggle_file() {
  local file="$1"

  # Check if file exists in git
  if ! git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    echo "Not tracked: $file"
    return
  fi

  # Check current flag
  local flag
  flag=$(git ls-files -v "$file" | cut -c1)

  if [[ "$flag" == "S" ]]; then
    git update-index --no-skip-worktree "$file"
    echo "UNSKIPPED: $file"
  else
    git update-index --skip-worktree "$file"
    echo "SKIPPED:   $file"
  fi
}

for file in "${FILES[@]}"; do
  toggle_file "$file"
done
