#!/usr/bin/env bash
set -euo pipefail

power_supply_dir=${LOCK_STATUS_POWER_SUPPLY_DIR:-/sys/class/power_supply}

escape_markup() {
    local value=${1:-}
    value=${value//&/&amp;}
    value=${value//</&lt;}
    value=${value//>/&gt;}
    value=${value//\"/&quot;}
    value=${value//\'/&apos;}
    printf '%s' "$value"
}

get_host_name() {
    if [[ -r /proc/sys/kernel/hostname ]]; then
        local host
        host=$(< /proc/sys/kernel/hostname)
        printf '%s' "${host%%.*}"
        return 0
    fi

    uname -n 2>/dev/null | cut -d. -f1
}

get_battery_markup() {
    local battery capacity status status_label color

    for battery in "$power_supply_dir"/BAT*; do
        [[ -d "$battery" ]] || continue

        capacity=$(cat "$battery/capacity" 2>/dev/null || true)
        [[ "$capacity" =~ ^[0-9]+$ ]] || continue

        status=$(cat "$battery/status" 2>/dev/null || true)
        case "${status,,}" in
            charging)
                status_label='charging'
                ;;
            full)
                status_label='full'
                ;;
            discharging)
                status_label='on battery'
                ;;
            not\ charging)
                status_label='not charging'
                ;;
            *)
                status_label='battery'
                ;;
        esac
        color='#8BE9FD'

        printf "<span foreground='%s'>bat %s%% · %s</span>" "$color" "$(escape_markup "$capacity")" "$(escape_markup "$status_label")"
        return 0
    done

    return 1
}

user_name=$(escape_markup "${USER:-$(id -un 2>/dev/null || printf 'w0lf')}")
host_name=$(escape_markup "$(get_host_name || printf 'localhost')")
identity="<span foreground='#FFB86C'>${user_name} · ${host_name}</span>"

if battery_markup=$(get_battery_markup); then
    printf "%s <span foreground='#BD93F9'>·</span> %s\n" "$identity" "$battery_markup"
else
    printf "%s\n" "$identity"
fi
