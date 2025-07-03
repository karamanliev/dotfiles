#!/bin/bash

source "$HOME/dotfiles/.env"

VAULT="${OBSIDIAN_VAULT_PATH%/}"
ATTACH_DIR="$VAULT/attachments"

if [[ ! -d "$ATTACH_DIR" ]]; then
  echo "Attachment directory '$ATTACH_DIR' not found."
  exit 1
fi

DRY_RUN=1
if [[ "$1" == "-d" ]]; then
  DRY_RUN=0
fi

# Find all attachments
find "$ATTACH_DIR" -type f | while read -r ATTACH; do
  FILE=$(basename "$ATTACH")
  # Search for the filename in all notes, excluding attachments dir
  if ! grep -r --exclude-dir=attachments --include="*.md" --include="*.canvas" -- "$FILE" "$VAULT" >/dev/null; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "Unreferenced (dry run): $ATTACH"
    else
      echo "Deleting: $ATTACH"
      rm "$ATTACH"
    fi
  fi
done
