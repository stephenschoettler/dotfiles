#!/usr/bin/env bash
set -euo pipefail

repo="${HYPR_THEME_REPO:-$HOME/dev/dotfiles}"
theme_cmd="$repo/bin/hypr-theme"
preset_file="$repo/themes/transition-preset"
prompt="${HYPR_TRANSITION_PRESET_PROMPT:-Transition }"
width="${HYPR_TRANSITION_PRESET_WIDTH:-44}"
lines="${HYPR_TRANSITION_PRESET_LINES:-8}"

usage() {
    cat <<'EOF'
Usage: transition_preset_selector.sh [--print-menu] [--set PRESET]

Without arguments, open fuzzel and store the selected transition-origin preset.
EOF
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "transition_preset_selector: missing command: $1" >&2
        exit 1
    }
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@"
    fi
}

current_preset() {
    if [[ -f "$preset_file" ]]; then
        tr '[:upper:]' '[:lower:]' <"$preset_file" | tr -d '[:space:]'
    else
        printf 'cursor\n'
    fi
}

menu_lines() {
    local current preset label
    current="$(current_preset)"
    while IFS='|' read -r preset label; do
        [[ -n "$preset" ]] || continue
        if [[ "$preset" == "$current" ]]; then
            printf '%s  %s [current]\n' "$preset" "$label"
        else
            printf '%s  %s\n' "$preset" "$label"
        fi
    done <<'EOF'
cursor|follow cursor
center|grow from center
top-left|grow from top left
top-right|grow from top right
bottom-left|grow from bottom left
bottom-right|grow from bottom right
random|random origin
EOF
}

choose_preset() {
    if [[ -n "${HYPR_TRANSITION_PRESET_CHOICE:-}" ]]; then
        printf '%s\n' "$HYPR_TRANSITION_PRESET_CHOICE"
        return 0
    fi

    require_cmd fuzzel

    menu_lines | fuzzel --dmenu \
        --match-mode=fuzzy \
        --only-match \
        --prompt "$prompt" \
        --width "$width" \
        --lines "$lines"
}

normalize_preset() {
    printf '%s\n' "${1%% *}"
}

validate_preset() {
    case "$1" in
        cursor|center|top-left|top-right|bottom-left|bottom-right|random)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

main() {
    local selection="" preset=""

    while (($#)); do
        case "$1" in
            --print-menu)
                menu_lines
                return 0
                ;;
            --set)
                shift
                [[ $# -gt 0 ]] || {
                    echo "transition_preset_selector: --set requires a preset" >&2
                    exit 1
                }
                selection="$1"
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                echo "transition_preset_selector: unknown argument: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done

    if [[ -z "$selection" ]]; then
        selection="$(choose_preset || true)"
    fi

    [[ -n "$selection" ]] || return 0

    preset="$(normalize_preset "$selection")"
    validate_preset "$preset" || {
        echo "transition_preset_selector: invalid preset: $preset" >&2
        exit 1
    }

    mkdir -p "$(dirname "$preset_file")"
    printf '%s\n' "$preset" >"$preset_file"
    notify "Transition preset saved" "$preset"
}

main "$@"
