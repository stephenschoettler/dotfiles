#!/bin/bash
# Path to the file that stores the last used color index
INDEX_FILE="/tmp/tmux_color_index"

# Dracula accents: Cyan, Green, Orange, Yellow, Pink, Purple
COLORS=("#8be9fd" "#50fa7b" "#ffb86c" "#f1fa8c" "#ff79c6" "#bd93f9")
NUM_COLORS=${#COLORS[@]}

# Read or initialize index
if [ -f "$INDEX_FILE" ]; then
    LAST_INDEX=$(cat "$INDEX_FILE")
else
    LAST_INDEX=-1
fi

# Increment and wrap
CURRENT_INDEX=$(( (LAST_INDEX + 1) % NUM_COLORS ))
COLOR=${COLORS[$CURRENT_INDEX]}

# Save index
echo "$CURRENT_INDEX" > "$INDEX_FILE"

# Set color for the CURRENT window. 
# MATCHES .tmux.conf STYLE: No extra separators, just simple powerline arrows.
tmux setw window-status-current-format "#[bg=$COLOR,fg=#282a36] #I  #W #[bg=#282a36,fg=$COLOR]"

exit 0