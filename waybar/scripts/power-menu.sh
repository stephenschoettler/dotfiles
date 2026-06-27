#!/usr/bin/env bash
set -euo pipefail

if ! command -v fuzzel >/dev/null 2>&1; then
    echo "Missing: fuzzel" >&2
    exit 1
fi

menu() {
    fuzzel --dmenu --only-match --match-mode=fuzzy --prompt "$1" --placeholder "Action" --width 30 --lines "$2"
}

confirm() {
    local action=$1 selected
    selected=$(printf '%s\n%s\n' "Cancel" "$action" | menu "$action? " 2)
    [[ "$selected" == "$action" ]]
}

selected=$(printf '%s\n' Lock Suspend Logout Reboot Shutdown Cancel | menu "Power " 6)

case "$selected" in
    Lock)
        exec loginctl lock-session
        ;;
    Suspend)
        exec systemctl suspend
        ;;
    Logout)
        confirm Logout && hyprctl dispatch exit
        ;;
    Reboot)
        confirm Reboot && systemctl reboot
        ;;
    Shutdown)
        confirm Shutdown && systemctl poweroff -i
        ;;
    Cancel|"")
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
