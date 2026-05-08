#!/usr/bin/env bash
# Shared Hyprland monitor detection helpers. Source this from other scripts.

hypr_require_cmds() {
    local missing=0
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Missing required command: $cmd" >&2
            missing=1
        fi
    done
    return "$missing"
}

hypr_active_monitors_json() {
    hyprctl monitors -j
}

hypr_laptop_monitor() {
    local monitors_json=${1:-}

    if [[ -z "$monitors_json" ]]; then
        monitors_json=$(hypr_active_monitors_json) || return 1
    fi

    jq -r '
        (
          ([.[] | select(((.disabled // false) | not) and ((.name // "") | test("^eDP-"))) | .name] | .[0])
          // ([.[] | select(((.disabled // false) | not) and ((.description // "") | contains("California Institute of Technology 0x161D"))) | .name] | .[0])
          // ([.[] | select(((.disabled // false) | not) and ((.make // "") | contains("California Institute of Technology"))) | .name] | .[0])
          // ([.[] | select(((.disabled // false) | not) and ((.model // "") | contains("0x161D"))) | .name] | .[0])
          // empty
        )
    ' <<<"$monitors_json"
}

hypr_external_monitor() {
    local monitors_json=${1:-}

    if [[ -z "$monitors_json" ]]; then
        monitors_json=$(hypr_active_monitors_json) || return 1
    fi

    jq -r '
        (
          ([.[] | select(
              ((.disabled // false) | not) and
              (((.name // "") | test("^eDP-")) | not) and
              (
                ((.description // "") | contains("ASUSTek COMPUTER INC XG258")) or
                ((.make // "") | contains("ASUSTek COMPUTER INC")) or
                ((.model // "") | contains("XG258"))
              )
            ) | .name] | .[0])
          // ([.[] | select(((.disabled // false) | not) and (((.name // "") | test("^eDP-")) | not))] | sort_by(.x, .y, .id) | .[0].name)
          // empty
        )
    ' <<<"$monitors_json"
}

hypr_external_count() {
    local monitors_json=${1:-}

    if [[ -z "$monitors_json" ]]; then
        monitors_json=$(hypr_active_monitors_json) || return 1
    fi

    jq -r '[.[] | select(((.disabled // false) | not) and (((.name // "") | test("^eDP-")) | not))] | length' <<<"$monitors_json"
}

hypr_focused_monitor() {
    local monitors_json=${1:-}

    if [[ -z "$monitors_json" ]]; then
        monitors_json=$(hypr_active_monitors_json) || return 1
    fi

    jq -r '([.[] | select(.focused == true) | .name] | .[0]) // empty' <<<"$monitors_json"
}

hypr_profile_status() {
    local monitors_json laptop external external_count focused mode

    monitors_json=$(hypr_active_monitors_json) || return 1
    laptop=$(hypr_laptop_monitor "$monitors_json")
    external=$(hypr_external_monitor "$monitors_json")
    external_count=$(hypr_external_count "$monitors_json")
    focused=$(hypr_focused_monitor "$monitors_json")

    if [[ -z "$laptop" ]]; then
        printf 'mode=error laptop= external=%s focused=%s externals=%s external_count=%s\n' "$external" "$focused" "$external_count" "$external_count"
        return 2
    fi

    if [[ -n "$external" ]]; then
        mode="dual"
    else
        mode="laptop-only"
    fi

    printf 'mode=%s laptop=%s external=%s focused=%s externals=%s external_count=%s\n' "$mode" "$laptop" "$external" "$focused" "$external_count" "$external_count"
}

hypr_is_laptop_monitor_name() {
    local monitor_name=${1:-}
    [[ "$monitor_name" =~ ^eDP- ]]
}

hypr_notify() {
    local title=${1:-Hyprland}
    local body=${2:-}

    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$body" >/dev/null 2>&1 || true
    fi
}
