#!/bin/bash

# Get the list of sink names
# We use grep to filter out any potentially empty lines if any, though cut usually handles it.
mapfile -t sinks_array < <(pactl list short sinks | cut -f2)

# Get current default sink
current_sink=$(pactl get-default-sink)

# Find index of current sink
current_index=-1
for i in "${!sinks_array[@]}"; do
   if [[ "${sinks_array[$i]}" = "${current_sink}" ]]; then
       current_index=$i
       break
   fi
done

# If current sink not found (weird state), default to 0
if [ $current_index -eq -1 ]; then
    current_index=0
fi

# Calculate next index
next_index=$(( (current_index + 1) % ${#sinks_array[@]} ))
next_sink=${sinks_array[$next_index]}

# Set new default sink
pactl set-default-sink "$next_sink"

# Move all current inputs to the new sink
pactl list short sink-inputs | cut -f1 | while read -r input; do
    pactl move-sink-input "$input" "$next_sink"
done
