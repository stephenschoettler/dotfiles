#!/bin/bash

if command -v nvidia-smi &>/dev/null; then
  # Get Utilization and Temperature
  STATS=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits)

  # Parse into variables
  IFS=',' read -r TEMP UTIL <<<"$STATS"

  # Clean whitespace
  TEMP=$(echo "$TEMP" | tr -d '[:space:]')
  UTIL=$(echo "$UTIL" | tr -d '[:space:]')

  bar() {
    local pct=$1
    local width=5
    local full=$((pct * width / 100))
    local bar=""
    for ((i=0; i<full; i++)); do bar+="█"; done
    for ((i=full; i<width; i++)); do bar+="░"; done
    echo "$bar"
  }

  if [ -n "$UTIL" ]; then
    # Display: GPU 12% 45°C with a pipe separator on the right
    # Matches the formatting in .tmux.conf
    UTILBAR=$(bar $UTIL)
    printf ' #[fg=#ff79c6]󰍹 [%s] %3s%% #[fg=#6272a4]│' "${UTILBAR}" "$UTIL"
  fi
else
  echo ""
fi

