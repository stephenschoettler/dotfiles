#!/usr/bin/env bash
set -euo pipefail

/home/w0lf/.config/hypr/scripts/render_hyprlock_clock.py >/dev/null
pidof hyprlock >/dev/null || exec hyprlock
