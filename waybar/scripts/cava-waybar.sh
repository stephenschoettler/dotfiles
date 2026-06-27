#!/usr/bin/env bash
set -o pipefail

conf="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/cava.conf"
blocks=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

coproc CAVA_PROC { cava -p "$conf" 2>/dev/null; }
cava_pid="$CAVA_PROC_PID"

cleanup() {
    if [[ -n "${cava_pid:-}" ]]; then
        kill "$cava_pid" 2>/dev/null || true
        wait "$cava_pid" 2>/dev/null || true
    fi
}
trap 'cleanup; exit 0' PIPE TERM INT EXIT

declare -a previous=()

while IFS= read -r line <&"${CAVA_PROC[0]}"; do
    output=""
    IFS=';' read -r -a values <<< "$line"
    index=0
    for value in "${values[@]}"; do
        [[ "$value" =~ ^[0-9]+$ ]] || continue
        (( value < 0 )) && value=0
        (( value > 7 )) && value=7

        prev="${previous[$index]:-$value}"
        if (( value > prev )); then
            smoothed=$(((prev + value + 1) / 2))
        else
            smoothed=$(((prev * 2 + value) / 3))
        fi
        (( smoothed < 0 )) && smoothed=0
        (( smoothed > 7 )) && smoothed=7

        previous[$index]="$smoothed"
        output+="${blocks[$smoothed]}"
        ((index++))
    done
    printf '%s\n' "$output" 2>/dev/null || exit 0
done
