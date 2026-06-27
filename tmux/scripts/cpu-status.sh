#!/usr/bin/env bash
set -euo pipefail

cache="${XDG_RUNTIME_DIR:-/tmp}/tmux-cpu-stat-${UID}"

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
idle_all=$((idle + iowait))
non_idle=$((user + nice + system + irq + softirq + steal))
total=$((idle_all + non_idle))

cpu=0
if [ -r "$cache" ]; then
  read -r prev_total prev_idle < "$cache" || true
  if [ -n "${prev_total:-}" ] && [ -n "${prev_idle:-}" ]; then
    total_delta=$((total - prev_total))
    idle_delta=$((idle_all - prev_idle))
    if [ "$total_delta" -gt 0 ]; then
      cpu=$((((total_delta - idle_delta) * 100 + total_delta / 2) / total_delta))
    fi
  fi
fi

printf '%s %s\n' "$total" "$idle_all" > "$cache"
printf '#[fg=#8be9fd]CPU %3s%%' "$cpu"
