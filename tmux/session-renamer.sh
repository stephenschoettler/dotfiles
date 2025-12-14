#!/bin/bash

current_session=$(tmux display-message -p '#S')

# Only rename if the current session is "0" or "main"
if [[ "$current_session" == "0" ]] || [[ "$current_session" == "main" ]]; then
    new_id=1
    while tmux has-session -t "$new_id" 2>/dev/null; do
        ((new_id++))
    done
    tmux rename-session "$new_id"
fi
