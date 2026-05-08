#!/usr/bin/env bash
# Screenshot a focused, laptop, or external output using runtime monitor detection.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DISPLAY_PROFILE="$SCRIPT_DIR/display_profile.sh"
TARGET=${1:-focused}
SCREENSHOT_DIR="$HOME/pictures/screenshots"

notify() {
    command -v notify-send >/dev/null 2>&1 && notify-send "Hyprland" "$*" >/dev/null 2>&1 || true
}

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

status=$("$DISPLAY_PROFILE" status) || { notify "Could not detect display profile"; exit 1; }
parse_status "$status"

case "$TARGET" in
    focused)
        output=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name // empty')
        ;;
    laptop)
        output=$laptop
        ;;
    external)
        output=$external
        ;;
    *)
        echo "Usage: ${0##*/} <focused|laptop|external>" >&2
        exit 2
        ;;
esac

if [[ -z "${output:-}" ]]; then
    notify "No $TARGET output available"
    exit 1
fi

mkdir -p "$SCREENSHOT_DIR"
hyprshot -m output -m "$output" -o "$SCREENSHOT_DIR" -f "Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
