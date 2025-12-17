#!/bin/bash
# Try to attach to an existing session (most recent), otherwise create a new one.
if tmux has-session 2>/dev/null; then
    tmux attach-session
else
    tmux new-session
fi
