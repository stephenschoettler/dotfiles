#!/bin/bash
for cmd in cliphist wofi wl-copy; do
    command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done
cliphist list | wofi --dmenu | cliphist decode | wl-copy
