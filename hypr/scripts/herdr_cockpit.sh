#!/usr/bin/env bash

set -euo pipefail

readonly WINDOW_CLASS="herdr-cockpit"
readonly WINDOW_TITLE="Herdr Agent Cockpit"
readonly WORKSPACE_NAME="agents"
readonly RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
readonly LOCK_FILE="${RUNTIME_DIR}/herdr-cockpit-${UID}.lock"

command -v hyprctl >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v flock >/dev/null 2>&1 || exit 0

exec 9>"$LOCK_FILE"
flock -x 9

find_cockpit_address() {
    hyprctl clients -j 2>/dev/null \
        | jq -r --arg class "$WINDOW_CLASS" \
            'first(.[] | select(.class == $class) | .address) // empty'
}

cockpit_workspace() {
    local address=$1

    hyprctl clients -j 2>/dev/null \
        | jq -r --arg address "$address" \
            'first(.[] | select(.address == $address) | .workspace.name) // empty'
}

using_lua_provider() {
    hyprctl systeminfo 2>/dev/null | grep -q '^configProvider: lua$'
}

focus_cockpit() {
    local address=$1
    local workspace

    if using_lua_provider; then
        hyprctl dispatch "hl.dsp.focus({ window = 'address:${address}' })" >/dev/null 2>&1 || true
        workspace=$(cockpit_workspace "$address")
        if [[ "$workspace" != "$WORKSPACE_NAME" ]]; then
            hyprctl dispatch "hl.dsp.window.move({ workspace = 'name:${WORKSPACE_NAME}', follow = true })" >/dev/null 2>&1 || true
        fi
        hyprctl dispatch "hl.dsp.focus({ workspace = 'name:${WORKSPACE_NAME}' })" >/dev/null 2>&1 || true
        hyprctl dispatch "hl.dsp.focus({ window = 'address:${address}' })" >/dev/null 2>&1 || true
        return
    fi

    workspace=$(cockpit_workspace "$address")
    if [[ "$workspace" != "$WORKSPACE_NAME" ]]; then
        hyprctl dispatch movetoworkspacesilent "name:${WORKSPACE_NAME},address:${address}" >/dev/null 2>&1 || true
    fi
    hyprctl dispatch workspace "name:${WORKSPACE_NAME}" >/dev/null 2>&1 || true
    hyprctl dispatch focuswindow "address:${address}" >/dev/null 2>&1 || true
}

address=$(find_cockpit_address)
if [[ -n "$address" ]]; then
    focus_cockpit "$address"
    exit 0
fi

command -v kitty >/dev/null 2>&1 || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

# Do not let detached Kitty inherit the lock descriptor or caller's stdio.
kitty --detach --class "$WINDOW_CLASS" --title "$WINDOW_TITLE" herdr \
    9>&- </dev/null >/dev/null 2>&1

# Keep the lock until the compositor registers the new client. A second launch
# waits here, then finds and focuses the same window instead of creating another.
for _ in {1..100}; do
    address=$(find_cockpit_address)
    if [[ -n "$address" ]]; then
        focus_cockpit "$address"
        exit 0
    fi
    sleep 0.1
done

exit 0
