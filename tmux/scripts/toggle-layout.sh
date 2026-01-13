#!/usr/bin/env bash

# Check current state variable (defaults to horizontal/tiled usually, so we start by toggling to vertical)
state=$(tmux show-window-option -v @layout_toggle_state 2>/dev/null)

if [ "$state" == "vertical" ]; then
    tmux select-layout even-horizontal
    tmux set-window-option @layout_toggle_state horizontal
    tmux display-message "Layout: Horizontal"
else
    tmux select-layout even-vertical
    tmux set-window-option @layout_toggle_state vertical
    tmux display-message "Layout: Vertical"
fi
