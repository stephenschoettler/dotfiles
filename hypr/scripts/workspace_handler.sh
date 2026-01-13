#!/bin/bash

# --- Configuration ---
LAPTOP_MONITOR="eDP-1"
EXTERNAL_MONITOR="HDMI-A-1"
# ---------------------

# Arguments
ACTION=$1
BASE=$2

if [[ -z "$BASE" ]]; then
    # Default fallback if something goes wrong
    exit 1
fi

# Map 0 to 10
if [[ "$BASE" -eq 0 ]]; then
    BASE=10
fi

ALT=$((BASE + 10))

# Get formatted monitors JSON once
MONITORS_INFO=$(hyprctl monitors -j)
WORKSPACES_INFO=$(hyprctl workspaces -j)

# Get Active Monitor
CURRENT_MONITOR=$(echo "$MONITORS_INFO" | jq -r '.[] | select(.focused == true).name')

# Find monitors for the pair
MON_BASE=$(echo "$WORKSPACES_INFO" | jq -r ".[] | select(.id == $BASE).monitor")
MON_ALT=$(echo "$WORKSPACES_INFO" | jq -r ".[] | select(.id == $ALT).monitor")

TARGET=""

if [[ "$ACTION" == "movetoworkspace" ]]; then
    # Move active window to workspace logic
    # We move to the workspace associated with the CURRENT monitor, or default
    if [[ "$MON_BASE" == "$CURRENT_MONITOR" ]]; then
        TARGET=$BASE
    elif [[ "$MON_ALT" == "$CURRENT_MONITOR" ]]; then
        TARGET=$ALT
    else
        # Fallback: Current monitor has neither?
        # Use standard convention: Laptop -> Base, External -> Alt
        if [[ "$CURRENT_MONITOR" == "$EXTERNAL_MONITOR" ]]; then
            TARGET=$ALT
        else
            TARGET=$BASE
        fi
    fi
    hyprctl dispatch movetoworkspace "$TARGET"

elif [[ "$ACTION" == "workspace" ]]; then
    # Switch workspace logic
    if [[ "$MON_BASE" == "$CURRENT_MONITOR" ]]; then
        TARGET=$BASE
    elif [[ "$MON_ALT" == "$CURRENT_MONITOR" ]]; then
        TARGET=$ALT
    else
        # Neither is on current monitor.
        # Check standard assignment
        if [[ "$CURRENT_MONITOR" == "$EXTERNAL_MONITOR" ]]; then
            TARGET=$ALT
        else
            TARGET=$BASE
        fi
    fi
    hyprctl dispatch workspace "$TARGET"
fi
