#!/usr/bin/env bash
set -euo pipefail

# Waybar backlight actions.
# left-click: toggle current brightness with comfortable default (60%)
# right-click: cycle coarse presets (25/50/75/100)

ACTION="${1:-toggle}"
DEVICE="${BRIGHTNESS_DEVICE:-nvidia_wmi_ec_backlight}"
BRIGHTNESSCTL="${BRIGHTNESSCTL:-brightnessctl}"
TARGET_PERCENT="${BRIGHTNESS_TARGET_PERCENT:-60}"
TOLERANCE_PERCENT="${BRIGHTNESS_TOLERANCE_PERCENT:-3}"
PRESETS_CSV="${BRIGHTNESS_PRESETS:-25,50,75,100}"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
STATE_FILE="$STATE_DIR/brightness-${DEVICE}.prev"

current_raw() {
    "$BRIGHTNESSCTL" -d "$DEVICE" -m get
}

max_raw() {
    "$BRIGHTNESSCTL" -d "$DEVICE" -m max
}

current_percent() {
    local current max
    current="$(current_raw)"
    max="$(max_raw)"
    if [[ ! "$current" =~ ^[0-9]+$ || ! "$max" =~ ^[0-9]+$ || "$max" -le 0 ]]; then
        echo "Could not read brightness for device: $DEVICE" >&2
        exit 1
    fi
    echo $(((current * 100 + max / 2) / max))
}

set_percent() {
    "$BRIGHTNESSCTL" -d "$DEVICE" -q set "$1%"
}

set_raw() {
    "$BRIGHTNESSCTL" -d "$DEVICE" -q set "$1"
}

is_valid_raw() {
    [[ "${1:-}" =~ ^[0-9]+$ ]]
}

is_near_target() {
    local percent="$1"
    (( percent >= TARGET_PERCENT - TOLERANCE_PERCENT && percent <= TARGET_PERCENT + TOLERANCE_PERCENT ))
}

toggle_comfort() {
    local percent previous
    percent="$(current_percent)"

    mkdir -p "$STATE_DIR"

    if is_near_target "$percent" && [[ -r "$STATE_FILE" ]]; then
        previous="$(<"$STATE_FILE")"
        if is_valid_raw "$previous"; then
            set_raw "$previous"
            rm -f "$STATE_FILE"
            exit 0
        fi
    fi

    current_raw > "$STATE_FILE"
    set_percent "$TARGET_PERCENT"
}

cycle_presets() {
    local percent preset first next
    percent="$(current_percent)"
    IFS=',' read -r -a presets <<< "$PRESETS_CSV"
    first="${presets[0]}"
    next="$first"

    for preset in "${presets[@]}"; do
        [[ "$preset" =~ ^[0-9]+$ ]] || continue
        if (( percent < preset )); then
            next="$preset"
            break
        fi
    done

    set_percent "$next"
}

case "$ACTION" in
    toggle|toggle-comfort)
        toggle_comfort
        ;;
    cycle|cycle-presets)
        cycle_presets
        ;;
    *)
        echo "Usage: $0 {toggle|cycle}" >&2
        exit 2
        ;;
esac
