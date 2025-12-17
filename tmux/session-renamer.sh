#!/bin/bash

current_session=$(tmux display-message -p '#S')

# Only proceed if the current session name is numeric (ignore named sessions like "dev")
if [[ "$current_session" =~ ^[0-9]+$ ]]; then

    # Find the maximum session ID among OTHER sessions
    # 1. List all sessions
    # 2. Exclude the current session
    # 3. Keep only numeric sessions
    # 4. Sort numerically descending
    # 5. Take the top one (max)
    max_id=$(tmux list-sessions -F '#S' | \
             grep -v "^${current_session}$" | \
             grep -E '^[0-9]+$' | \
             sort -rn | \
             head -n 1)

    # If no other sessions exist, max_id is 0
    if [[ -z "$max_id" ]]; then
        max_id=0
    fi

    # If the current session ID is filling a gap (i.e., <= max_id), 
    # rename it to the end of the line (max_id + 1).
    if (( current_session <= max_id )); then
        new_id=$((max_id + 1))
        tmux rename-session "$new_id"
    fi
fi

