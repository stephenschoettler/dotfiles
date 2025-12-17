#!/bin/bash

# 1. Try to find the lowest existing unattached session (numeric only)
# list-sessions -f "#{==:#{session_attached},0}" : List only unattached
# -F "#{session_name}" : Print session name
# grep -E '^[0-9]+$' : Keep only numeric sessions
# sort -n : Sort numerically (1, 2, 10...)
# head -n 1 : Pick the first (lowest)
target=$(tmux list-sessions -f "#{==:#{session_attached},0}" -F "#{session_name}" 2>/dev/null | grep -E '^[0-9]+$' | sort -n | head -n 1)

if [[ -n "$target" ]]; then
    echo "Attaching to existing unattached session: $target"
    exec tmux attach-session -t "$target"
fi

# 2. If no unattached sessions exist, find the lowest available number to create
i=1
while true; do
    if ! tmux has-session -t "$i" 2>/dev/null; then
        echo "Creating new session: $i"
        exec tmux new-session -s "$i"
        break
    fi
    ((i++))
done
