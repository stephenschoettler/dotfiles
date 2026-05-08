#!/usr/bin/env bash
# Detect and reconcile the active Hyprland display/workspace profile.
# Modes:
#   status  -> print: mode=<mode> laptop=<output> external=<output> focused=<output> externals=<n>
#   apply   -> apply monitor layout and workspace placement using runtime outputs
#   repair  -> force a renderer reload, then apply and focus the laptop workspace 1

set -euo pipefail

SCRIPT_NAME=${0##*/}
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=monitor_lib.sh
source "$SCRIPT_DIR/monitor_lib.sh"

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr"
STATE_FILE="$STATE_DIR/display_profile.state"
NOTIFY=0

for arg in "$@"; do
    case "$arg" in
        --notify) NOTIFY=1 ;;
    esac
done

notify() {
    if [[ "$NOTIFY" -ne 1 && "${DISPLAY_PROFILE_NOTIFY:-0}" != "1" ]]; then
        return 0
    fi
    hypr_notify "Hyprland" "$*"
}

die() {
    echo "$SCRIPT_NAME: $*" >&2
    notify "Display profile error: $*"
    exit 1
}

parse_status() {
    local status=$1 kv key value
    mode=""
    laptop=""
    external=""
    focused=""
    externals="0"
    external_count="0"

    for kv in $status; do
        key=${kv%%=*}
        value=${kv#*=}
        case "$key" in
            mode) mode=$value ;;
            laptop) laptop=$value ;;
            external) external=$value ;;
            focused) focused=$value ;;
            externals) externals=$value ;;
            external_count) external_count=$value ;;
        esac
    done

    if [[ "$external_count" == "0" && "$externals" != "0" ]]; then
        external_count=$externals
    fi
}

keyword_monitor() {
    local rule=$1 out
    if ! out=$(hyprctl keyword monitor "$rule" 2>&1); then
        die "failed monitor rule '$rule': $out"
    fi
}

move_workspace() {
    local workspace=$1 monitor=$2
    hyprctl -q dispatch moveworkspacetomonitor "$workspace" "$monitor" >/dev/null 2>&1 || true
}

apply_profile() {
    local status state previous

    status=$(hypr_profile_status) || die "could not detect an active laptop monitor"
    parse_status "$status"

    [[ -n "$laptop" ]] || die "no laptop monitor detected"

    mkdir -p "$STATE_DIR" 2>/dev/null || true
    if [[ -r "$STATE_FILE" ]]; then
        previous=$(<"$STATE_FILE")
    else
        previous=""
    fi

    case "$mode" in
        dual)
            [[ -n "$external" ]] || die "dual mode selected without an external monitor"

            # External on the left, laptop to the right. Use runtime output names.
            keyword_monitor "$external,highrr,0x0,1"
            sleep 0.15
            keyword_monitor "$laptop,preferred,auto-right,1.25"

            for i in {1..10}; do
                move_workspace "$i" "$laptop"
            done
            for i in {11..20}; do
                move_workspace "$i" "$external"
            done

            state="mode=dual laptop=$laptop external=$external"
            if [[ "${external_count:-0}" -gt 1 ]]; then
                notify "Multiple external monitors detected; using $external"
            fi
            ;;
        laptop-only)
            keyword_monitor "$laptop,preferred,0x0,1.25"

            for i in {1..20}; do
                move_workspace "$i" "$laptop"
            done

            state="mode=laptop-only laptop=$laptop external="
            ;;
        *)
            die "unhandled display mode: $mode"
            ;;
    esac

    printf '%s\n' "$state" >"$STATE_FILE" 2>/dev/null || true

    if [[ "$previous" != "$state" ]]; then
        case "$mode" in
            dual) notify "Display profile: dual ($external left, $laptop right)" ;;
            laptop-only) notify "Display profile: laptop only ($laptop)" ;;
        esac
    fi

    printf '%s\n' "$status"
}

repair_profile() {
    local status
    NOTIFY=1
    hyprctl -q dispatch forcerendererreload >/dev/null 2>&1 || true
    status=$(apply_profile)
    parse_status "$status"
    if [[ -n "$laptop" ]]; then
        hyprctl -q dispatch focusmonitor "$laptop" >/dev/null 2>&1 || true
        hyprctl -q dispatch workspace 1 >/dev/null 2>&1 || true
    fi
    printf '%s\n' "$status"
}

usage() {
    cat <<USAGE
Usage: $SCRIPT_NAME <status|apply|repair> [--notify]
USAGE
}

hypr_require_cmds hyprctl jq || exit 1

command=${1:-status}
case "$command" in
    status) hypr_profile_status ;;
    apply) apply_profile ;;
    repair) repair_profile ;;
    -h|--help|help) usage ;;
    *) usage >&2; exit 2 ;;
esac
