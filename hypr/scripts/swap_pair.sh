#!/usr/bin/env bash
# Send the focused window to the requested pair slot on the other monitor.
# Usage: ./swap_pair.sh [0-9]
# If argument is 1, the pair is 1/11.
# Logic in dual-monitor mode:
# - If the focused window is on the monitor currently owning slot 1, move to slot 11.
# - If the focused window is on the monitor currently owning slot 11, move to slot 1.
# - Honors the live workspace placement, so global workspace swaps keep working.
# Laptop-only mode falls back to the base workspace so windows stay reachable.

set -u

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=monitor_lib.sh
source "$SCRIPT_DIR/monitor_lib.sh"

hypr_require_cmds hyprctl jq || exit 1

usage() {
    echo "Usage: ${0##*/} <0-9|10> [--dry-run]" >&2
}

other_monitor() {
    local monitor=${1:-}

    if [[ -n "$laptop" && "$monitor" == "$laptop" && -n "$external" ]]; then
        printf '%s\n' "$external"
    elif [[ -n "$external" && "$monitor" == "$external" && -n "$laptop" ]]; then
        printf '%s\n' "$laptop"
    else
        printf '\n'
    fi
}

workspace_monitor() {
    local workspace_id=$1

    jq -r --argjson id "$workspace_id" \
        '[.[] | select(.id == $id)][0].monitor // empty' <<<"$WORKSPACES_INFO"
}

group_monitor() {
    local start=$1 end=$2

    jq -r --argjson start "$start" --argjson end "$end" '
        [
          .[]
          | select((.id >= $start) and (.id <= $end) and ((.monitor // "") != ""))
          | .monitor
        ]
        | group_by(.)
        | map({monitor: .[0], count: length})
        | sort_by(.count)
        | last.monitor // empty
    ' <<<"$WORKSPACES_INFO"
}

KEY=${1:-}
DRY_RUN=0
if [[ "${2:-}" == "--dry-run" ]]; then
    DRY_RUN=1
fi

if [[ -z "$KEY" || ! "$KEY" =~ ^[0-9]+$ ]]; then
    usage
    exit 2
fi

BASE=$KEY
if [[ "$BASE" -eq 0 ]]; then
    BASE=10
fi

if (( BASE < 1 || BASE > 10 )); then
    usage
    exit 2
fi

ALT=$((BASE + 10))

MONITORS_INFO=$(hypr_active_monitors_json)
WORKSPACES_INFO=$(hyprctl workspaces -j)
laptop=$(hypr_laptop_monitor "$MONITORS_INFO")
external=$(hypr_external_monitor "$MONITORS_INFO")

CURRENT_WS=$(hyprctl activewindow -j | jq -r '.workspace.id // empty')
if [[ "$CURRENT_WS" == "null" || -z "$CURRENT_WS" ]]; then
    hypr_notify "Hyprland" "No active window to move"
    exit 1
fi

CURRENT_MONITOR=$(workspace_monitor "$CURRENT_WS")
if [[ -z "$CURRENT_MONITOR" ]]; then
    CURRENT_MONITOR=$(hypr_focused_monitor "$MONITORS_INFO")
fi

# No other monitor exists. Keep the old safe behavior: use base workspaces only.
if [[ -z "$external" ]]; then
    TARGET=$BASE
else
    BASE_MONITOR=$(workspace_monitor "$BASE")
    ALT_MONITOR=$(workspace_monitor "$ALT")
    BASE_GROUP_MONITOR=$(group_monitor 1 10)
    ALT_GROUP_MONITOR=$(group_monitor 11 20)

    [[ -n "$BASE_MONITOR" ]] || BASE_MONITOR=$BASE_GROUP_MONITOR
    [[ -n "$ALT_MONITOR" ]] || ALT_MONITOR=$ALT_GROUP_MONITOR

    # Infer the missing side from the other side when only one half currently exists.
    if [[ -z "$BASE_MONITOR" && -n "$ALT_MONITOR" ]]; then
        BASE_MONITOR=$(other_monitor "$ALT_MONITOR")
    fi
    if [[ -z "$ALT_MONITOR" && -n "$BASE_MONITOR" ]]; then
        ALT_MONITOR=$(other_monitor "$BASE_MONITOR")
    fi

    # Final fallback to the default display profile layout.
    [[ -n "$BASE_MONITOR" ]] || BASE_MONITOR=$laptop
    [[ -n "$ALT_MONITOR" ]] || ALT_MONITOR=$external

    if [[ "$CURRENT_MONITOR" == "$BASE_MONITOR" ]]; then
        TARGET=$ALT
    elif [[ "$CURRENT_MONITOR" == "$ALT_MONITOR" ]]; then
        TARGET=$BASE
    else
        # Unknown/manual monitor placement: choose the workspace that lives on the
        # opposite known monitor when possible, otherwise fall back to base.
        OTHER=$(other_monitor "$CURRENT_MONITOR")
        if [[ -n "$OTHER" && "$BASE_MONITOR" == "$OTHER" ]]; then
            TARGET=$BASE
        elif [[ -n "$OTHER" && "$ALT_MONITOR" == "$OTHER" ]]; then
            TARGET=$ALT
        else
            TARGET=$BASE
        fi
    fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'key=%s base=%s alt=%s current_ws=%s current_monitor=%s base_monitor=%s alt_monitor=%s target=%s\n' \
        "$KEY" "$BASE" "$ALT" "$CURRENT_WS" "$CURRENT_MONITOR" "${BASE_MONITOR:-}" "${ALT_MONITOR:-}" "$TARGET"
    exit 0
fi

hyprctl dispatch movetoworkspace "$TARGET" >/dev/null
