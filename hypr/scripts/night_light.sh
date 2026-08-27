#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/hyprsunset-night-light.state"
temperature="${NIGHT_LIGHT_TEMPERATURE:-4500}"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Night Light" "$*" >/dev/null 2>&1 || true
}

json_escape() {
    python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

ensure_daemon() {
    if ! command -v hyprsunset >/dev/null 2>&1; then
        notify "hyprsunset is not installed"
        return 1
    fi
    if ! pgrep -x hyprsunset >/dev/null 2>&1; then
        hyprsunset >/tmp/hyprsunset.log 2>&1 &
        sleep 0.4
    fi
}

is_on() {
    [[ -f "$state_file" ]] && [[ "$(<"$state_file")" == "on" ]] && pgrep -x hyprsunset >/dev/null 2>&1
}

status_json() {
    local class text tooltip
    local icon_pad=$'\u2009'
    local night_icon="󰖔${icon_pad}"

    if ! command -v hyprsunset >/dev/null 2>&1; then
        text="󰖔"
        class="missing"
        tooltip="hyprsunset not installed"
    elif is_on; then
        text="$night_icon"
        class="on"
        tooltip="Night light on (${temperature}K)"
    else
        text="$night_icon"
        class="off"
        tooltip="Night light off"
    fi

    printf '{"text":"%s","class":"%s","tooltip":%s}\n' \
        "$text" "$class" "$(printf '%s' "$tooltip" | json_escape)"
}

case "${1:-toggle}" in
    toggle)
        ensure_daemon || exit 0
        if [[ -f "$state_file" && "$(cat "$state_file")" == "on" ]]; then
            hyprctl hyprsunset identity >/dev/null
            printf 'off' > "$state_file"
            notify "Off"
        else
            hyprctl hyprsunset temperature "$temperature" >/dev/null
            printf 'on' > "$state_file"
            notify "On (${temperature}K)"
        fi
        ;;
    on)
        ensure_daemon || exit 0
        hyprctl hyprsunset temperature "$temperature" >/dev/null
        printf 'on' > "$state_file"
        notify "On (${temperature}K)"
        ;;
    off)
        ensure_daemon || exit 0
        hyprctl hyprsunset identity >/dev/null
        printf 'off' > "$state_file"
        notify "Off"
        ;;
    status)
        status_json
        ;;
    status-bool)
        if is_on; then
            printf 'true\n'
        else
            printf 'false\n'
        fi
        ;;
    *)
        echo "Usage: ${0##*/} [toggle|on|off|status|status-bool]" >&2
        exit 2
        ;;
esac
