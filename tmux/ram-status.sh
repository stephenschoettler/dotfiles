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
RAM=$(free --mega | awk '/^Mem:/ {printf "%.0f", $3/$2 *100}')
printf ' #[fg=#ffb86c] [%s] %3s%%' "$(bar $RAM)" "$RAM"
