#!/usr/bin/env bash
# Move the active workspace to the previous/next monitor by runtime geometry.

set -euo pipefail

DIRECTION=${1:-next}

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Hyprland" "$*" >/dev/null 2>&1 || true
}

case "$DIRECTION" in
    next|prev) ;;
    *) echo "Usage: ${0##*/} <next|prev>" >&2; exit 2 ;;
esac

mapfile -t monitors < <(hyprctl monitors -j | jq -r 'sort_by(.x, .y)[] | .name')
count=${#monitors[@]}

if (( count < 2 )); then
    notify "Only one monitor is active"
    exit 0
fi

current=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name // empty')
workspace=$(hyprctl activeworkspace -j | jq -r '.id // empty')

if [[ -z "$current" || -z "$workspace" || "$workspace" == "null" ]]; then
    notify "Could not determine active workspace/monitor"
    exit 1
fi

current_index=-1
for i in "${!monitors[@]}"; do
    if [[ "${monitors[$i]}" == "$current" ]]; then
        current_index=$i
        break
    fi
done

if (( current_index < 0 )); then
    notify "Focused monitor is not in active monitor list"
    exit 1
fi

if [[ "$DIRECTION" == "next" ]]; then
    target_index=$(( (current_index + 1) % count ))
else
    target_index=$(( (current_index - 1 + count) % count ))
fi

target=${monitors[$target_index]}
hyprctl dispatch moveworkspacetomonitor "$workspace" "$target" >/dev/null
hyprctl dispatch focusmonitor "$target" >/dev/null 2>&1 || true
