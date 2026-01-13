# Hyprland Helper Scripts

This directory contains various shell scripts used to enhance the Hyprland experience. These scripts handle workspace management, clipboard history, UI elements, and system interactions.

## Scripts

### `cliphist_selector.sh`
**Description:** Launches a clipboard history selector using `wofi` and `cliphist`.
**Usage:** Bind to a key (e.g., `SUPER + V`) to quickly select and copy items from your clipboard history.
**Dependencies:** `cliphist`, `wofi`, `wl-clipboard`

### `get_ascii_time.sh`
**Description:** Generates a 3-line ASCII art representation of the current time (including AM/PM and Date). The output is formatted with Pango markup, specifically designed for `hyprlock`.
**Style:** Uses the Dracula color theme (Green #50FA7B) for the text.

### `greeting.sh`
**Description:** Outputs a simple greeting message (e.g., "Hi, user! :)").
**Usage:** Intended for use in status bars or lock screens (like `hyprlock`) to display a personalized welcome message.

### `swap_pair.sh`
**Description:** Moves the currently focused window between a "base" workspace and its paired workspace (Base + 10).
**Logic:**
- If the window is on Workspace 1, it moves to Workspace 11.
- If the window is on Workspace 11, it moves to Workspace 1.
- Otherwise, it moves to the Base workspace.
**Usage:** `./swap_pair.sh <workspace_number>` (e.g., `./swap_pair.sh 1`)

### `swap_workspaces.sh`
**Description:** Toggles the assignment of workspace groups between two monitors (Laptop and External).
**Functionality:**
- **Normal Mode:** Workspaces 1-10 on Laptop, 11-20 on External.
- **Inverted Mode:** Workspaces 1-10 on External, 11-20 on Laptop.
**Usage:** Execute to instantly swap entire workspace groups between screens.

### `workspace_handler.sh`
**Description:** Advanced workspace switching logic that respects monitor context. It determines whether to switch to the "Base" workspace (e.g., 1) or its "Alt" pair (e.g., 11) based on which monitor is currently focused.
**Usage:**
- Switch workspace: `./workspace_handler.sh workspace <base_num>`
- Move window: `./workspace_handler.sh movetoworkspace <base_num>`
