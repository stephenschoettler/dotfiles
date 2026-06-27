#!/usr/bin/env bash
set -euo pipefail

if ! command -v swayosd-server >/dev/null 2>&1; then
    exit 0
fi

style="${XDG_CONFIG_HOME:-$HOME/.config}/swayosd/style.css"
exec swayosd-server -s "$style"
