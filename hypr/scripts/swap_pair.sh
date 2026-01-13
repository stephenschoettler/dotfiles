#!/bin/bash

# Move the focused window to the target workspace or its pair.
# Usage: ./swap_pair.sh [0-9]
# If argument is 1, pair is 11.
# Logic:
# - If active window is on 1, move to 11.
# - If active window is on 11, move to 1.
# - Else, move to 1.

TARGET_KEY=$1

if [[ -z "$TARGET_KEY" ]]; then
    notify-send "Hyprland" "Usage: $0 <workspace_num>"
    exit 1
fi

# Handle 0 -> 10 mapping
if [[ "$TARGET_KEY" -eq 0 ]]; then
    BASE=10
else
    BASE=$TARGET_KEY
fi

ALT=$((BASE + 10))

# Get current workspace of the focused window
CURRENT_WS=$(hyprctl activewindow -j | jq -r ".workspace.id")

# Check for valid window/workspace
if [[ "$CURRENT_WS" == "null" || -z "$CURRENT_WS" ]]; then
    notify-send "Hyprland" "No active window to move"
    exit 1
fi

if [[ "$CURRENT_WS" -eq "$BASE" ]]; then
    # Window is on Base, move to Alt
    hyprctl dispatch movetoworkspace "$ALT"
elif [[ "$CURRENT_WS" -eq "$ALT" ]]; then
    # Window is on Alt, move to Base
    hyprctl dispatch movetoworkspace "$BASE"
else
    # Window is elsewhere, move to Base
    hyprctl dispatch movetoworkspace "$BASE"
fi

