#!/bin/sh

folder="$HOME/Documents/notes/"

new_note() {
    name="$(
        rofi -no-config -dmenu \
            -theme "Arc-Dark" \
            -p "➕ Enter Note Name" -i -l 1
    )"
    case "$name" in
    "")
        selected
        ;;
    *)
        kitty --app-id=dmenu-notes --title="Dmenu Notes" --name=dmenu-notes --single-instance --execute nvim $folder"$name.md" >/dev/null 2>&1
        ;;
    esac
}

selected() {
    choice="$(echo -e "New Note\n$(ls -t1 $folder | sed 's/\.md$//')" |
        rofi -no-config -dmenu -theme "Arc-Dark" \
            -p "🗒️ Select Note" -i -l 20 \
            -kb-remove-char-forward "" -kb-delete-entry "" -kb-custom-1 "Ctrl+d")"

    exit_code=$?

    case "$choice" in
    "New Note")
        new_note
        ;;
    "")
        exit
        ;;
    *)
        if [[ -n "$choice" && "$choice" != "New Note" ]]; then
            if [[ "$exit_code" -eq 10 ]]; then

                delete_choice="$(echo -e "Yes\nNo" |
                    rofi -no-config -dmenu \
                        -theme "Arc-Dark" \
                        -p "❌ Delete Note?" -i -l 2)"
                if [[ "$delete_choice" == "Yes" ]]; then
                    rm "$folder$choice.md"
                    notify-send "Note \"$choice\" deleted."
                fi
                selected

            else
                kitty --app-id=dmenu-notes --title="Dmenu Notes" --name=dmenu-notes --single-instance --execute nvim "$folder$choice.md" >/dev/null 2>&1
            fi
        else
            exit
        fi
        ;;
    esac
}

selected
