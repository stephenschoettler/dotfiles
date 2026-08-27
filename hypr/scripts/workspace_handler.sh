#!/usr/bin/env bash
# Context-aware workspace switch/move for the paired workspace model.
# Uses live workspace placement, so it still works after global workspace swaps.

set -u

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=monitor_lib.sh
source "$SCRIPT_DIR/monitor_lib.sh"

hypr_require_cmds hyprctl jq || exit 1

usage() {
    echo "Usage: ${0##*/} <workspace|movetoworkspace> <0-9|10>" >&2
}

ACTION=${1:-}
KEY=${2:-}

case "$ACTION" in
    workspace|movetoworkspace) ;;
    *) usage; exit 2 ;;
esac

if [[ ! "$KEY" =~ ^[0-9]+$ ]]; then
    usage
    exit 2
fi

BASE=$KEY
if [[ "$BASE" -eq 0 ]]; then
    BASE=10
fi

if (( BASE < 1 || BASE > 10 )); then
    echo "Workspace key must be 0-9 or 10" >&2
    exit 2
fi

ALT=$((BASE + 10))

MONITORS_INFO=$(hypr_active_monitors_json)
WORKSPACES_INFO=$(hyprctl workspaces -j)
CURRENT_MONITOR=$(hypr_focused_monitor "$MONITORS_INFO")
EXTERNAL_MONITOR=$(hypr_external_monitor "$MONITORS_INFO")

MON_BASE=$(jq -r --argjson id "$BASE" '[.[] | select(.id == $id)][0].monitor // empty' <<<"$WORKSPACES_INFO")
MON_ALT=$(jq -r --argjson id "$ALT" '[.[] | select(.id == $id)][0].monitor // empty' <<<"$WORKSPACES_INFO")

fallback_target_for_current_monitor() {
    # Laptop-only or ambiguous focus should never target unavailable alt workspaces.
    if [[ -n "$EXTERNAL_MONITOR" && -n "$CURRENT_MONITOR" ]] && ! hypr_is_laptop_monitor_name "$CURRENT_MONITOR"; then
        printf '%s\n' "$ALT"
    else
        printf '%s\n' "$BASE"
    fi
}

target_for_pair() {
    # Laptop-only always uses base workspaces so number keys do not jump to 11-20.
    if [[ -z "$EXTERNAL_MONITOR" ]]; then
        printf '%s\n' "$BASE"
        return
    fi

    # If either member of the pair already lives on this monitor, follow reality.
    # This preserves the global swap workflow where 1-10 and 11-20 can be inverted.
    if [[ -n "$CURRENT_MONITOR" && "$MON_BASE" == "$CURRENT_MONITOR" ]]; then
        printf '%s\n' "$BASE"
    elif [[ -n "$CURRENT_MONITOR" && "$MON_ALT" == "$CURRENT_MONITOR" ]]; then
        printf '%s\n' "$ALT"
    else
        fallback_target_for_current_monitor
    fi
}

TARGET=$(target_for_pair)

case "$ACTION" in
    workspace)
        hyprctl dispatch "hl.dsp.focus({ workspace = \"$TARGET\" })" >/dev/null
        ;;
    movetoworkspace)
        hyprctl dispatch "hl.dsp.window.move({ workspace = $TARGET })" >/dev/null
        ;;
esac
