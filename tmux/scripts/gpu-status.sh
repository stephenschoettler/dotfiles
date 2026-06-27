#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvidia-smi >/dev/null 2>&1; then
  exit 0
fi

cache="${XDG_RUNTIME_DIR:-/tmp}/tmux-gpu-status-${UID}"
now=$(date +%s)

if [ -r "$cache" ]; then
  IFS=$'\t' read -r cached_at cached_output < "$cache" || true
  if [ -n "${cached_at:-}" ] && [ $((now - cached_at)) -lt 10 ]; then
    printf '%s' "${cached_output:-}"
    exit 0
  fi
fi

util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 | tr -d '[:space:]')
[ -n "${util:-}" ] || exit 0

output=$(printf '#[fg=#ff79c6]GPU %3s%%' "$util")
printf '%s\t%s\n' "$now" "$output" > "$cache"
printf '%s' "$output"
