#!/usr/bin/env bash
set -euo pipefail

repo="${HYPR_THEME_REPO:-$HOME/dev/dotfiles}"
theme_cmd="$repo/bin/hypr-theme"
current=""

if [[ -x "$theme_cmd" ]]; then
    current="$($theme_cmd current 2>/dev/null || true)"
fi

if command -v awww-daemon >/dev/null 2>&1 && command -v awww >/dev/null 2>&1; then
    pkill -x hyprpaper >/dev/null 2>&1 || true
    if ! awww query >/dev/null 2>&1; then
        awww-daemon --quiet >/dev/null 2>&1 &
        sleep 0.3
    fi
    if [[ -n "$current" && -x "$theme_cmd" ]]; then
        "$theme_cmd" apply "$current" --wallpaper-only --transition-type none >/dev/null 2>&1 || awww restore >/dev/null 2>&1 || true
    else
        awww restore >/dev/null 2>&1 || true
    fi
    exit 0
fi

if command -v hyprpaper >/dev/null 2>&1; then
    pgrep -x hyprpaper >/dev/null 2>&1 || hyprpaper >/dev/null 2>&1 &
fi
