#!/usr/bin/env bash
# Toggle the paired workspace groups between the detected laptop and external monitor.

set -u

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=monitor_lib.sh
source "$SCRIPT_DIR/monitor_lib.sh"

hypr_require_cmds hyprctl jq || exit 1

parse_status() {
    local status=$1 kv key value
    mode=""
    laptop=""
    external=""

    for kv in $status; do
        key=${kv%%=*}
        value=${kv#*=}
        case "$key" in
            mode) mode=$value ;;
            laptop) laptop=$value ;;
            external) external=$value ;;
        esac
    done
}

set_workspace_rule() {
    local workspace=$1 monitor=$2
    hyprctl keyword workspace "$workspace, monitor:$monitor" >/dev/null 2>&1 || true
}

move_range() {
    local start=$1 end=$2 monitor=$3 i
    for ((i = start; i <= end; i++)); do
        set_workspace_rule "$i" "$monitor"
        hyprctl -q dispatch moveworkspacetomonitor "$i" "$monitor" >/dev/null 2>&1 || true
    done
}

status=$(hypr_profile_status) || { hypr_notify "Hyprland" "Could not detect display profile"; exit 1; }
parse_status "$status"

if [[ "$mode" != "dual" || -z "$external" ]]; then
    move_range 1 20 "$laptop"
    hypr_notify "Hyprland" "No external monitor detected; restored laptop-only layout"
    exit 0
fi

MON_1=$(hyprctl workspaces -j | jq -r '.[] | select(.id == 1).monitor // empty')

if [[ "$MON_1" == "$external" ]]; then
    move_range 1 10 "$laptop"
    move_range 11 20 "$external"
    hypr_notify "Hyprland" "Global swap: restored default layout"
else
    move_range 1 10 "$external"
    move_range 11 20 "$laptop"
    hypr_notify "Hyprland" "Global swap: inverted workspaces"
fi
