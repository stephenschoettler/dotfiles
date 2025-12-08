#!/bin/bash

if command -v nvidia-smi &>/dev/null; then
  # Get Utilization and Temperature
  STATS=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits)

  # Parse into variables
  IFS=',' read -r TEMP UTIL <<<"$STATS"

  # Clean whitespace
  TEMP=$(echo "$TEMP" | tr -d '[:space:]')
  UTIL=$(echo "$UTIL" | tr -d '[:space:]')

  if [ -n "$UTIL" ]; then
    # Display: GPU 12% 45°C with a pipe separator on the right
    # Matches the formatting in .tmux.conf
    echo " #[fg=#ff79c6]󰍹 ${UTIL}% ${TEMP}°C #[fg=#6272a4]│"
  fi
else
  echo ""
fi

