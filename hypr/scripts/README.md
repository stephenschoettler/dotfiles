# Hyprland Helper Scripts

This directory contains shell helpers for the Hyprland session: display hotplug reconciliation, workspace routing, clipboard history, lock-screen text, screenshots, and system interactions.

## Display / monitor hotplug

### `monitor_lib.sh`
**Description:** Shared runtime monitor detection helpers used by the display and workspace scripts. Not intended to be run directly.

### `display_profile.sh`
**Description:** Detects the active laptop output and external output from `hyprctl monitors -j`, then reconciles monitor layout and workspace placement.

**Commands:**
- `./display_profile.sh status` prints `mode=<mode> laptop=<output> external=<output> focused=<output> externals=<n>`.
- `./display_profile.sh apply` applies the current profile.
- `./display_profile.sh repair` applies the profile, then focuses the laptop and workspace 1.

**Policy:**
- Dual monitor: external at `0x0`, laptop to the right, workspaces `1-10` on laptop and `11-20` on external.
- Laptop-only: laptop at `0x0`, workspaces `1-20` moved to the laptop so windows remain reachable.

### `monitor_hotplug_watcher.sh`
**Description:** Watches Hyprland socket2 events and runs `display_profile.sh apply` after `monitoradded`, `monitorremoved`, or `configreloaded` events.

**Notes:**
- Uses `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`.
- Debounces events for about one second.
- Uses a runtime lock so only one watcher remains active.

## Workspace management

### `workspace_handler.sh`
**Description:** Context-aware workspace switching for the paired workspace model.

**Logic:**
- In dual mode, if the external monitor is focused, key `N` targets workspace `N+10`.
- Otherwise, key `N` targets workspace `N`.
- In laptop-only mode, key `N` always targets workspace `N` so windows are not sent to unavailable outputs.

**Usage:**
- Switch workspace: `./workspace_handler.sh workspace <base_num>`
- Move window: `./workspace_handler.sh movetoworkspace <base_num>`

### `swap_pair.sh`
**Description:** Moves the focused window between a base workspace and its paired workspace.

**Logic:**
- If the window is on workspace `1`, it moves to `11`.
- If the window is on workspace `11`, it moves to `1`.
- Otherwise, it moves to the base workspace.

**Usage:** `./swap_pair.sh <workspace_number>`

### `swap_workspaces.sh`
**Description:** Toggles the assignment of workspace groups between the detected laptop and external monitor.

**Functionality:**
- Default: workspaces `1-10` on laptop, `11-20` on external.
- Inverted: workspaces `1-10` on external, `11-20` on laptop.
- Laptop-only: restores the laptop-only profile and exits.

### `move_current_workspace_to_monitor.sh`
**Description:** Moves the active workspace to the previous or next active monitor by runtime monitor geometry. This avoids hard-coded monitor names.

**Usage:**
- `./move_current_workspace_to_monitor.sh next`
- `./move_current_workspace_to_monitor.sh prev`

## Screenshots

### `screenshot_output.sh`
**Description:** Screenshots a runtime-detected output.

**Usage:**
- `./screenshot_output.sh focused`
- `./screenshot_output.sh laptop`
- `./screenshot_output.sh external`

## Other scripts

### `cliphist_selector.sh`
**Description:** Launches a Dracula-styled clipboard history selector using `wofi` and `cliphist`.
**Behavior:** Includes a clear-history row with a second confirmation before `cliphist wipe`.
**Style:** `cliphist_selector.css`
**Dependencies:** `awk`, `cliphist`, `wofi`, `wl-clipboard`

### `get_ascii_time.sh`
**Description:** Generates a 3-line ASCII art representation of the current time for `hyprlock`.

### `greeting.sh`
**Description:** Outputs a simple greeting message for status bars or lock screens.
