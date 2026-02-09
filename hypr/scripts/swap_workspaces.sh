#!/bin/bash

# Global swap script.
# Infers state by checking where Workspace 1 is.
# If Workspace 1 is on Laptop -> Normal -> Swap to External.
# If Workspace 1 is on External -> Swapped -> Swap to Laptop.

for cmd in hyprctl jq notify-send; do
    command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done

LAPTOP_MONITOR="eDP-2"
EXTERNAL_MONITOR="HDMI-A-1"

# Get location of Workspace 1
MON_1=$(hyprctl workspaces -j | jq -r '.[] | select(.id == 1).monitor')

if [[ "$MON_1" == "$EXTERNAL_MONITOR" ]]; then
    # Currently Swapped (1 is on External). Restore to Normal.
    echo "Restoring to Normal Layout..."
    
    # 1-10 -> Laptop
    for i in {1..10}; do
        hyprctl dispatch moveworkspacetomonitor "$i" "$LAPTOP_MONITOR"
    done
    # 11-20 -> External
    for i in {11..20}; do
        hyprctl dispatch moveworkspacetomonitor "$i" "$EXTERNAL_MONITOR"
    done
    notify-send "Hyprland" "Global Swap: Restored to Default"

else
    # Currently Normal (or mixed/undefined). Force Swap.
    echo "Swapping to Inverted Layout..."
    
    # 1-10 -> External
    for i in {1..10}; do
        hyprctl dispatch moveworkspacetomonitor "$i" "$EXTERNAL_MONITOR"
    done
    # 11-20 -> Laptop
    for i in {11..20}; do
        hyprctl dispatch moveworkspacetomonitor "$i" "$LAPTOP_MONITOR"
    done
    notify-send "Hyprland" "Global Swap: Inverted Workspaces"
fi
