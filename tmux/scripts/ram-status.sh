#!/usr/bin/env bash
set -euo pipefail

ram=$(awk '
  /^MemTotal:/ { total=$2 }
  /^MemAvailable:/ { available=$2 }
  END {
    if (total > 0) {
      printf "%.0f", ((total - available) / total) * 100
    } else {
      printf "0"
    }
  }
' /proc/meminfo)

printf '#[fg=#ffb86c]RAM %3s%%' "$ram"
