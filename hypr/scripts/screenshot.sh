#!/usr/bin/env bash
set -euo pipefail

mode=${1:-output}
target=${2:-focused}
screenshot_dir="${SCREENSHOT_DIR:-$HOME/pictures/screenshots}"
mkdir -p "$screenshot_dir"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Screenshot" "$*" >/dev/null 2>&1 || true
}

stamp() {
    date +'%Y-%m-%d_%H-%M-%S'
}

focused_output() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true).name // empty'
}

detected_output() {
    local which=${1:-focused}
    local script_dir status kv key value laptop="" external=""
    case "$which" in
        focused)
            focused_output
            ;;
        laptop|external)
            script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
            status=$("$script_dir/display_profile.sh" status)
            for kv in $status; do
                key=${kv%%=*}
                value=${kv#*=}
                case "$key" in
                    laptop) laptop=$value ;;
                    external) external=$value ;;
                esac
            done
            [[ "$which" == "laptop" ]] && printf '%s\n' "$laptop" || printf '%s\n' "$external"
            ;;
        *)
            printf '%s\n' "$which"
            ;;
    esac
}

capture_output() {
    local output file
    output=$(detected_output "$target")
    if [[ -z "$output" ]]; then
        notify "No $target output available"
        exit 1
    fi
    file="$screenshot_dir/Screenshot_$(stamp)_${output}.png"
    grim -o "$output" "$file"
    notify "Saved $file"
    printf '%s\n' "$file"
}

region_geometry() {
    slurp || exit 0
}

capture_region_file() {
    local geom file
    geom=$(region_geometry)
    [[ -n "$geom" ]] || exit 0
    file="$screenshot_dir/Screenshot_$(stamp)_region.png"
    grim -g "$geom" "$file"
    notify "Saved $file"
    printf '%s\n' "$file"
}

capture_region_clipboard() {
    local geom
    geom=$(region_geometry)
    [[ -n "$geom" ]] || exit 0
    grim -g "$geom" - | wl-copy --type image/png
    notify "Copied region to clipboard"
}

capture_region_edit() {
    local geom file
    geom=$(region_geometry)
    [[ -n "$geom" ]] || exit 0
    if command -v swappy >/dev/null 2>&1; then
        grim -g "$geom" - | swappy -f -
        notify "Opened region in Swappy"
    else
        file="$screenshot_dir/Screenshot_$(stamp)_region.png"
        grim -g "$geom" "$file"
        notify "Swappy missing; saved $file"
        printf '%s\n' "$file"
    fi
}

case "$mode" in
    output)
        capture_output
        ;;
    region)
        capture_region_file
        ;;
    clipboard)
        capture_region_clipboard
        ;;
    edit)
        capture_region_edit
        ;;
    *)
        echo "Usage: ${0##*/} <output [focused|laptop|external|name]|region|clipboard|edit>" >&2
        exit 2
        ;;
esac
