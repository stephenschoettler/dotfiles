#!/bin/bash

STYLE="$HOME/.config/waybar/scripts/wofi_ncenter.css"

# --- Configuration (matches waybar config) ---
# states: critical < 15, warning < 30, good >= 95
# icons array: 0-10, 10-20, ... 90-100 (11 icons total)
ICONS=("" "" "" "" "" "" "" "" "" "" "")

# --- Get Battery Info ---
capacity=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1)
status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1) # Charging, Discharging, Full, Unknown

# --- Determine Icon and Format ---
# Calculate index for icon array (capacity / 10)
# e.g., 95/10 = 9, 100/10 = 10.
# Bash integer division truncates.
idx=$(( capacity / 10 ))
if [ "$idx" -gt 10 ]; then idx=10; fi
base_icon="${ICONS[$idx]}"

if [[ "$status" == "Charging" ]]; then
    icon="󰂄"
    text="$capacity% $icon"
elif [[ "$status" == "Not charging" ]] || [[ "$status" == "Full" ]]; then
     # waybar uses plug icon for plugged, but let's stick to config "format-plugged" or "format-full" logic
     # config says: format-plugged: "{capacity}% "
     # config says: format-full: "{capacity}% {icon}"
    if [ "$capacity" -ge 98 ]; then
         text="$capacity% $base_icon"
    else
         text="$capacity% "
    fi
else
    # Discharging
    text="$capacity% $base_icon"
fi

# --- Show in Wofi ---
# We display the formatted string exactly like Waybar
echo "$text" | wofi --show dmenu \
    --prompt "Battery" \
    --location 3 \
    --x -45 \
    --y 50 \
    --width 200 \
    --height 100 \
    --cache-file /dev/null \
    --style "$STYLE"