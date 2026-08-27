#!/usr/bin/env bash
set -euo pipefail

# Desktop smoke check for Stephen's Hyprland dotfiles/live session.
# Prints PASS/FAIL/WARN lines and exits non-zero on hard failures.

failures=0
warnings=0

pass() { printf 'PASS %s\n' "$*"; }
warn() { printf 'WARN %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'FAIL %s\n' "$*"; failures=$((failures + 1)); }

have() {
    command -v "$1" >/dev/null 2>&1
}

check_command() {
    if have "$1"; then pass "command $1"; else fail "missing command $1"; fi
}

check_optional() {
    if have "$1"; then pass "optional command $1"; else warn "optional command $1 missing"; fi
}

check_json() {
    if jq empty "$1" >/dev/null 2>&1; then pass "valid JSON $1"; else fail "invalid JSON $1"; fi
}

check_shell() {
    if bash -n "$1" >/dev/null 2>&1; then pass "shell syntax $1"; else fail "shell syntax $1"; fi
}

check_cmp() {
    if cmp -s "$1" "$2"; then pass "synced $2"; else warn "differs $2"; fi
}

check_process() {
    if pgrep -x "$1" >/dev/null 2>&1; then pass "process $1 running"; else warn "process $1 not running"; fi
}

printf 'Hyprland desktop health\n'
printf '=======================\n'

for cmd in hyprctl jq waybar swaync swaync-client fuzzel cliphist wl-copy grim slurp brightnessctl wpctl; do
    check_command "$cmd"
done
for cmd in swayosd-server swayosd-client hyprsunset swappy; do
    check_optional "$cmd"
done
if have hyprpolkitagent || [[ -x /usr/lib/hyprpolkitagent/hyprpolkitagent ]] || systemctl --user list-unit-files hyprpolkitagent.service >/dev/null 2>&1; then
    pass "optional command hyprpolkitagent"
else
    warn "optional command hyprpolkitagent missing"
fi

config_errors=$(hyprctl configerrors 2>&1 || true)
if [[ -z "$config_errors" || "$config_errors" == "ok" ]]; then
    pass "hyprctl configerrors clean"
else
    fail "hyprctl configerrors: $config_errors"
fi

check_json /home/w0lf/dev/dotfiles/waybar/config
check_json /home/w0lf/.config/waybar/config
check_json /home/w0lf/dev/dotfiles/swaync/config.json
check_json /home/w0lf/.config/swaync/config.json

if fuzzel --check-config --config /home/w0lf/dev/dotfiles/fuzzel/fuzzel.ini >/dev/null 2>&1; then
    pass "fuzzel config"
else
    fail "fuzzel config"
fi

for script in /home/w0lf/dev/dotfiles/hypr/scripts/*.sh /home/w0lf/dev/dotfiles/waybar/scripts/*.sh; do
    [[ -f "$script" ]] && check_shell "$script"
done

check_cmp /home/w0lf/dev/dotfiles/hypr/hyprland.lua /home/w0lf/.config/hypr/hyprland.lua
check_cmp /home/w0lf/dev/dotfiles/hypr/theme.lua /home/w0lf/.config/hypr/theme.lua
check_cmp /home/w0lf/dev/dotfiles/hypr/hyprsunset.conf /home/w0lf/.config/hypr/hyprsunset.conf
check_cmp /home/w0lf/dev/dotfiles/fuzzel/fuzzel.ini /home/w0lf/.config/fuzzel/fuzzel.ini
check_cmp /home/w0lf/dev/dotfiles/swayosd/style.css /home/w0lf/.config/swayosd/style.css
check_cmp /home/w0lf/dev/dotfiles/swaync/style.css /home/w0lf/.config/swaync/style.css
check_cmp /home/w0lf/dev/dotfiles/swaync/config.json /home/w0lf/.config/swaync/config.json
check_cmp /home/w0lf/dev/dotfiles/waybar/style.css /home/w0lf/.config/waybar/style.css
check_cmp /home/w0lf/dev/dotfiles/waybar/config /home/w0lf/.config/waybar/config
for script in /home/w0lf/dev/dotfiles/waybar/scripts/*.sh; do
    live_script="/home/w0lf/.config/waybar/scripts/${script##*/}"
    check_cmp "$script" "$live_script"
done

check_process Hyprland
check_process waybar
check_process swaync
check_process hypridle
if have swayosd-server; then check_process swayosd-server; fi
if have hyprsunset; then check_process hyprsunset; fi
if [[ -x /usr/lib/hyprpolkitagent/hyprpolkitagent ]] || systemctl --user list-unit-files hyprpolkitagent.service >/dev/null 2>&1; then
    if pgrep -f '/usr/lib/hyprpolkitagent/hyprpolkitagent' >/dev/null 2>&1; then
        pass "process hyprpolkitagent running"
    else
        warn "process hyprpolkitagent not running"
    fi
fi

printf '\nSummary: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
(( failures == 0 ))
