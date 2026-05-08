#!/usr/bin/env bash
# Listen to Hyprland socket2 monitor events and debounce display reconciliation.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DISPLAY_PROFILE="$SCRIPT_DIR/display_profile.sh"
DEBOUNCE_SECONDS=${DEBOUNCE_SECONDS:-1}
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr"
LOCK_FILE="$RUNTIME_DIR/monitor_hotplug_watcher.lock"

have() {
    command -v "$1" >/dev/null 2>&1
}

notify_error() {
    have notify-send && notify-send "Hyprland" "Hotplug watcher: $*" >/dev/null 2>&1 || true
}

instance_signature() {
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        printf '%s\n' "$HYPRLAND_INSTANCE_SIGNATURE"
        return 0
    fi

    hyprctl instances -j 2>/dev/null | jq -r '.[0].instance // empty'
}

socket_path() {
    local sig
    sig=$(instance_signature)
    [[ -n "$sig" ]] || return 1
    printf '%s/hypr/%s/.socket2.sock\n' "${XDG_RUNTIME_DIR:-/tmp}" "$sig"
}

schedule_apply() {
    local event=$1

    if [[ -n "${pending_pid:-}" ]] && kill -0 "$pending_pid" 2>/dev/null; then
        kill "$pending_pid" 2>/dev/null || true
    fi

    (
        sleep "$DEBOUNCE_SECONDS"
        DISPLAY_PROFILE_NOTIFY=1 "$DISPLAY_PROFILE" apply --notify >/dev/null 2>&1 || notify_error "apply failed after $event"
    ) &
    pending_pid=$!
}

cleanup() {
    [[ -n "${pending_pid:-}" ]] && kill "$pending_pid" 2>/dev/null || true
}

stop() {
    cleanup
    exit 0
}

main() {
    local sock line

    command -v hyprctl >/dev/null 2>&1 || { echo "monitor_hotplug_watcher.sh: missing hyprctl" >&2; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "monitor_hotplug_watcher.sh: missing jq" >&2; exit 1; }
    command -v socat >/dev/null 2>&1 || { echo "monitor_hotplug_watcher.sh: missing socat" >&2; exit 1; }
    [[ -x "$DISPLAY_PROFILE" ]] || { echo "monitor_hotplug_watcher.sh: missing executable $DISPLAY_PROFILE" >&2; exit 1; }

    mkdir -p "$RUNTIME_DIR" 2>/dev/null || true

    exec 9>"$LOCK_FILE"
    if have flock && ! flock -n 9; then
        exit 0
    fi

    trap cleanup EXIT
    trap stop INT TERM

    while true; do
        sock=$(socket_path || true)
        if [[ -z "$sock" || ! -S "$sock" ]]; then
            sleep 2
            continue
        fi

        while IFS= read -r line; do
            case "$line" in
                monitoradded*|monitorremoved*|configreloaded*)
                    schedule_apply "$line"
                    ;;
            esac
        done < <(socat -u "UNIX-CONNECT:$sock" - 2>/dev/null)

        sleep 1
    done
}

main "$@"
