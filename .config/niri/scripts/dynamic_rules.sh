#!/usr/bin/env zsh

function watch_windows() {
    local filter_count=$1
    shift
    local -a filter_list=("${@:1:$filter_count}")
    local -a cmd_list=("${@:$(($filter_count+1))}")

    if [[ ${#filter_list[@]} -eq 0 ]]; then
        echo "Usage: $0 [filter1] [filter2] ... -- [command1] [command2] ..."
        echo "Example: $0 'zen:Sign in.*' 'zen:Extension:.*' -- 'move-window-to-floating' 'set-window-width 30%' 'set-window-height 60%' 'center-window'"
        exit 1
    fi

    niri msg --json event-stream \
        | jq -rc --unbuffered 'select(.WindowOpenedOrChanged)
              | .WindowOpenedOrChanged.window
              | [.id, .app_id, .title] | @sh' \
        | while read -r line; do
        # Parse the shell-quoted line into an array
        eval "parts=($line)"

        local id="$parts[1]"
        local app="$parts[2]"
        local title="${(j: :)parts[3,-1]}"

        local key="$app:$title"

        local matches=false
        for filter in "${filter_list[@]}"; do
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
        echo "$icon [$app:$id] $title"

        if [[ "$matches" == "false" ]]; then
            continue
        fi

        for cmd in "${cmd_list[@]}"; do
            eval "niri msg action $cmd --id \"$id\""
        done

    done
}

# Parse arguments: filters before --, commands after --
local -a filter_list=()
local -a cmd_list=()
local parsing_filters=true

for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then
        parsing_filters=false
        continue
    fi

    if [[ "$parsing_filters" == "true" ]]; then
        filter_list+=("$arg")
    else
        cmd_list+=("$arg")
    fi
done

watch_windows ${#filter_list[@]} "${filter_list[@]}" "${cmd_list[@]}"

