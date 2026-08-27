#!/usr/bin/env bash
set -euo pipefail

repo="${HYPR_THEME_REPO:-$HOME/dev/dotfiles}"
theme_cmd="$repo/bin/hypr-theme"
preset_file="$repo/themes/transition-preset"
prompt="${HYPR_THEME_SELECTOR_PROMPT:-Theme }"
width="${HYPR_THEME_SELECTOR_WIDTH:-40}"
lines="${HYPR_THEME_SELECTOR_LINES:-8}"

usage() {
    cat <<'EOF'
Usage: theme_selector.sh [--print-menu] [--apply THEME] [--no-reload]

Without arguments, open fuzzel and apply the selected theme live.
EOF
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "theme_selector: missing command: $1" >&2
        exit 1
    }
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@"
    fi
}

menu_lines() {
    local current line theme preset
    current="$($theme_cmd current 2>/dev/null || true)"
    preset="$(current_preset)"

    while IFS= read -r line; do
        theme="${line#\* }"
        theme="${theme#  }"
        [[ -n "$theme" ]] || continue

        if [[ "$theme" == "$current" ]]; then
            printf '%s [current | %s]\n' "$theme" "$preset"
        else
            printf '%s\n' "$theme"
        fi
    done < <("$theme_cmd" list)
}

choose_theme() {
    if [[ -n "${HYPR_THEME_SELECTOR_CHOICE:-}" ]]; then
        printf '%s\n' "$HYPR_THEME_SELECTOR_CHOICE"
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

normalize_theme() {
    printf '%s\n' "${1%% *}"
}

current_preset() {
    if [[ -f "$preset_file" ]]; then
        tr '[:upper:]' '[:lower:]' <"$preset_file" | tr -d '[:space:]'
    else
        printf 'cursor\n'
    fi
}

preset_label() {
    case "$1" in
        cursor) printf 'follow cursor' ;;
        center) printf 'grow from center' ;;
        top-left) printf 'grow from top left' ;;
        top-right) printf 'grow from top right' ;;
        bottom-left) printf 'grow from bottom left' ;;
        bottom-right) printf 'grow from bottom right' ;;
        random) printf 'random origin' ;;
        *) printf '%s' "$1" ;;
    esac
}

notify_theme_status() {
    local title=$1 theme=$2 preset label
    preset="$(current_preset)"
    label="$(preset_label "$preset")"
    notify "$title" "$theme\ntransition: $preset ($label)"
}

main() {
    local selection="" theme="" current="" no_reload=0
    local -a extra_args=()

    while (($#)); do
        case "$1" in
            --print-menu)
                menu_lines
                return 0
                ;;
            --apply)
                shift
                [[ $# -gt 0 ]] || {
                    echo "theme_selector: --apply requires a theme id" >&2
                    exit 1
                }
                selection="$1"
                ;;
            --no-reload)
                no_reload=1
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                echo "theme_selector: unknown argument: $1" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done

    [[ -x "$theme_cmd" ]] || {
        echo "theme_selector: hypr-theme not executable: $theme_cmd" >&2
        exit 1
    }

    if [[ -z "$selection" ]]; then
        selection="$(choose_theme || true)"
    fi

    [[ -n "$selection" ]] || return 0

    theme="$(normalize_theme "$selection")"
    current="$($theme_cmd current 2>/dev/null || true)"

    if [[ "$theme" == "$current" ]]; then
        notify_theme_status "Theme unchanged" "$theme is already active"
        return 0
    fi

    if (( no_reload )); then
        extra_args+=(--no-reload)
    fi

    "$theme_cmd" apply "$theme" "${extra_args[@]}"
    notify_theme_status "Theme switched" "$theme"
}

main "$@"
