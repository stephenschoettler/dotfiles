#!/bin/bash
bar() {
  local pct=$1
  local width=5
  local full=$(((pct * width + 50) / 100))
  local bar=""
  for ((i=0; i<full; i++)); do bar+="█"; done
  for ((i=full; i<width; i++)); do bar+="░"; done
  echo "$bar"
}
CPU=$(top -bn1 | grep 'Cpu(s)' | awk '{print 100.0 - $8}' | cut -d. -f1)
printf ' #[fg=#8be9fd] [%s] %3s%%' "$(bar $CPU)" "$CPU"
