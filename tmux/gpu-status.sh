#!/bin/bash

if command -v nvidia-smi &> /dev/null; then
    # Get Utilization and Temperature
    # Output format example: 45, 12 (45 degrees, 12 percent)
    STATS=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits)
    
    # Parse into variables
    IFS=',' read -r TEMP UTIL <<< "$STATS"
    
    # Clean whitespace
    TEMP=$(echo "$TEMP" | tr -d '[:space:]')
    UTIL=$(echo "$UTIL" | tr -d '[:space:]')

    if [ -n "$UTIL" ]; then
        # Display: GPU: 12% 45°C
        echo "#[fg=#bd93f9]#[bg=#bd93f9,fg=#282a36] GPU: ${UTIL}% ${TEMP}°C "
    fi
else
    echo ""
fi