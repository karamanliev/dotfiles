#!/usr/bin/env zsh

function watch_windows() {
    niri msg --json event-stream \
        | jq -rc --unbuffered 'select(.WindowOpenedOrChanged)
              | .WindowOpenedOrChanged.window
              | [.id, .app_id, .title] | @sh' \
        | while read -r line; do
        # Parse the shell-quoted line into an array
        eval "parts=($line)"

        local id="$parts[1]"
        local app="$parts[2]"
        local title="${(j:,:)parts[3,-1]}"

        local key="$app:$title"
        local -a filters=(
            "zen:Sign in.*"
            "zen:Extension:.*"
        )

        local matches=false
        for filter in "${filters[@]}"; do
            if [[ "$key" =~ $filter ]]; then
                matches=true
                break
            fi
        done

        local icon
        if [[ "$matches" == "true" ]]; then
            icon="✅"
        else
            icon="❌"
        fi
        echo "$icon [$app:$id] $title "

        if [[ "$matches" == "false" ]]; then
            continue
        fi

        niri msg action move-window-to-floating --id "$id"
        niri msg action set-window-width "30%" --id "$id"
        niri msg action set-window-height "60%" --id "$id"
        niri msg action center-window --id "$id"

    done
}

watch_windows

