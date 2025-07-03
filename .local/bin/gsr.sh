#!/usr/bin/env bash

# Directories
rec_dir="$HOME/Videos/Recordings"
rep_dir="$HOME/Videos/Replays"
mkdir -p "$rec_dir" "$rep_dir"

# State files
state_dir="/tmp/gsr"
mkdir -p "$state_dir"
pid_file="$state_dir/gsr.pid"
mode_file="$state_dir/mode"
pause_file="$state_dir/paused"
monitor_file="$state_dir/monitor"
recording_file="$state_dir/recording_active"
last_recording_file="$state_dir/last_recording"

if [[ "$1" != "status" ]]; then
  monitor="${2:-DP-3}"
  echo "$monitor" >"$monitor_file"
else
  monitor=$(cat "$monitor_file" 2>/dev/null || echo "DP-3")
fi

# Common options
common_opts=(
  -w "$monitor"
  -f "60"
  -a "default_output|default_input"
)

# Helper functions
get_pid() {
  [[ -f "$pid_file" ]] && cat "$pid_file" 2>/dev/null || echo ""
}

is_running() {
  local pid=$(get_pid)
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

get_mode() {
  [[ -f "$mode_file" ]] && cat "$mode_file" 2>/dev/null || echo "none"
}

is_recording_active() {
  [[ -f "$recording_file" ]]
}

is_paused() {
  [[ -f "$pause_file" ]]
}

notify() {
  notify-send.sh -i gpu-screen-recorder -a "GPU Screen Recorder" "$@"
}

notify_with_buttons() {
  local summary="$1"
  local file="$2"
  local folder
  folder=$(dirname "$file")
  notify "$summary" "Saved to $file" \
    -o "Open Folder:xdg-open $folder" \
    -o "Play Video:xdg-open $file"
}

update_waybar() {
  pkill -RTMIN+1 waybar
}

# Main actions
start_recording() {
  local mode=$(get_mode)

  if [[ "$mode" == "replay" ]]; then
    # Recording within replay mode
    if is_recording_active; then
      notify "Already recording"
      return 1
    fi

    local pid=$(get_pid)
    kill -SIGRTMIN "$pid"
    touch "$recording_file"
    # notify "Started recording" "Will save to $rec_dir"
  elif [[ "$mode" == "recording" ]]; then
    notify "Already recording"
    return 1
  else
    # Start standalone recording
    local date=$(date +"%Y-%m-%d_%H-%M-%S")
    local video="$rec_dir/Video-${date}.mp4"
    echo "$video" >"$last_recording_file"

    gpu-screen-recorder "${common_opts[@]}" -o "$video" &
    echo $! >"$pid_file"
    echo "recording" >"$mode_file"
    rm -f "$pause_file"

    # notify "Started recording" "Saving to $video"
  fi

  update_waybar
}

stop_recording() {
  local mode=$(get_mode)

  if [[ "$mode" == "replay" ]] && is_recording_active; then
    # Stop recording within replay mode
    local pid=$(get_pid)
    kill -SIGRTMIN "$pid"
    rm -f "$recording_file"

    # Wait a moment for the file to be saved
    sleep 0.5

    # Find the most recent recording
    local latest_recording=$(find "$rec_dir" -name "*.mp4" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
    if [[ -n "$latest_recording" ]]; then
      notify_with_buttons "Recording saved" "$latest_recording"
    else
      notify "Stopped recording"
    fi
  elif [[ "$mode" == "recording" ]]; then
    # Stop standalone recording
    local pid=$(get_pid)
    local video=$(cat "$last_recording_file" 2>/dev/null || echo "$rec_dir/recording.mp4")

    kill -SIGINT "$pid"
    wait "$pid" 2>/dev/null

    rm -f "$pid_file" "$mode_file" "$pause_file" "$last_recording_file"

    if [[ -f "$video" ]]; then
      notify_with_buttons "Recording saved" "$video"
    else
      notify "Recording saved"
    fi
  else
    notify "No recording in progress"
    return 1
  fi

  update_waybar
}

toggle_pause() {
  local mode=$(get_mode)

  # Check if both recording and replay are active
  if [[ "$mode" == "replay" ]] && is_recording_active; then
    notify "Cannot pause while recording in replay mode"
    return 1
  elif [[ "$mode" == "recording" ]]; then
    local pid=$(get_pid)
    kill -SIGUSR2 "$pid"

    if is_paused; then
      rm -f "$pause_file"
      # notify "Recording resumed"
    else
      touch "$pause_file"
      # notify "Recording paused"
    fi

    update_waybar
  else
    notify "No recording in progress"
    return 1
  fi
}

start_replay() {
  if is_running; then
    local mode=$(get_mode)
    if [[ "$mode" == "replay" ]]; then
      notify "Replay buffer already active"
    else
      notify "GPU Screen Recorder already running in $mode mode"
    fi
    return 1
  fi

  gpu-screen-recorder "${common_opts[@]}" -c mp4 -r 60 -o "$rep_dir" -ro "$rec_dir" &
  echo $! >"$pid_file"
  echo "replay" >"$mode_file"

  # notify "Started replay buffer" "Will save to $rep_dir"
  update_waybar
}

stop_replay() {
  local mode=$(get_mode)

  if [[ "$mode" != "replay" ]]; then
    notify "No replay buffer active"
    return 1
  fi

  if is_recording_active; then
    local latest_recording=$(find "$rec_dir" -name "*.mp4" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
    if [[ -n "$latest_recording" ]]; then
      notify_with_buttons "Recording saved" "$latest_recording"
    else
      notify "Stopped recording"
    fi
  fi

  local pid=$(get_pid)
  kill -SIGINT "$pid"
  wait "$pid" 2>/dev/null

  rm -f "$pid_file" "$mode_file" "$recording_file" "$pause_file"

  # notify "Stopped replay buffer"
  update_waybar
}

save_replay() {
  local mode=$(get_mode)

  if [[ "$mode" != "replay" ]]; then
    notify "No replay buffer active"
    return 1
  fi

  local pid=$(get_pid)
  kill -SIGUSR1 "$pid"

  # Wait a moment for the file to be saved
  sleep 0.5

  # Find the most recent replay
  local latest_replay=$(find "$rep_dir" -name "*.mp4" -type f -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)
  if [[ -n "$latest_replay" ]]; then
    notify_with_buttons "Replay saved" "$latest_replay"
  else
    notify "Replay saved" "Saved to $rep_dir"
  fi
}

get_status() {
  local mode=$(get_mode)
  local recording=false
  local paused=false

  [[ "$mode" == "recording" ]] && recording=true
  [[ "$mode" == "replay" ]] && is_recording_active && recording=true
  is_paused && paused=true

  local alt text tooltip

  text="$monitor"
  if $recording && $paused; then
    alt="paused"
    tooltip="Recording is paused"
  elif [[ "$mode" == "replay" ]] && $recording; then
    alt="both"
    tooltip="Recording and replay buffer active"
  elif $recording; then
    alt="recording"
    tooltip="Recording in progress"
  elif [[ "$mode" == "replay" ]]; then
    alt="replay"
    tooltip="Replay buffer active"
  else
    alt="inactive"
    text=""
    tooltip="GPU Screen Recorder inactive"
  fi

  echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\", \"class\": \"$alt\", \"alt\": \"$alt\"}"
}

# Kill any orphaned processes on script start
cleanup_orphans() {
  local pid=$(get_pid)
  if [[ -n "$pid" ]] && ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$pid_file" "$mode_file" "$recording_file" "$pause_file" "$last_recording_file"
  fi
}

# Run cleanup on start
cleanup_orphans

# Main switch
case "$1" in
start)
  start_recording
  ;;
stop)
  stop_recording
  ;;
toggle-recording)
  if is_recording_active || [[ "$(get_mode)" == "recording" ]]; then
    stop_recording
  else
    start_recording
  fi
  ;;
pause)
  toggle_pause
  ;;
start-replay)
  start_replay
  ;;
stop-replay)
  stop_replay
  ;;
toggle-replay)
  if [[ "$(get_mode)" == "replay" ]]; then
    stop_replay
  else
    start_replay
  fi
  ;;
save-replay)
  save_replay
  ;;
status)
  get_status
  ;;
*)
  echo "Usage: $0 {start|stop|toggle-recording|pause|start-replay|stop-replay|toggle-replay|save-replay|status}"
  exit 1
  ;;
esac
