#!/bin/bash

# Directory containing the music files
MUSIC_DIR="$HOME/Music/"

# Function to update genre tags
update_genre() {
  local file="$1"
  local temp_file=$(mktemp)

  # Extract current genre tag
  local current_genre=$(vorbiscomment -l "$file" 2>/dev/null | grep -i "^genre=" | sed 's/^GENRE=//I')

  echo "Processing file: $file"

  if [ -z "$current_genre" ]; then
    echo "Current genre is empty or not found for: $file"
  else
    echo "Current genre: $current_genre"

    if [[ "$current_genre" == *","* ]]; then
      # Replace comma with semicolon
      local new_genre=$(echo "$current_genre" | sed 's/,/;/g')

      echo "New genre: $new_genre"

      # Remove existing GENRE tag and add the updated one
      vorbiscomment -l "$file" | grep -v -i "^genre=" >"$temp_file"
      echo "GENRE=$new_genre" >>"$temp_file"

      # Write the updated tags back to the file
      vorbiscomment -w -c "$temp_file" "$file"
      echo "Updated genre for: $file"
    else
      echo "No change needed for: $file"
    fi
  fi

  rm "$temp_file"
}

export -f update_genre

# Find all ogg files and update their genre tags
find "$MUSIC_DIR" -type f -name "*.ogg" -exec bash -c 'update_genre "$0"' {} \;
