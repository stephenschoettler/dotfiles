# Waybar Scripts

This directory contains helper scripts and stylesheets used by the Waybar configuration to provide interactive functionality, custom modules, and system controls.

## Scripts

### `cycle_audio_sink.sh`
**Purpose:** Cycles the default audio output device (sink) to the next available one.
- **Functionality:** 
    - Lists available PulseAudio/PipeWire sinks.
    - Identifies the current default sink.
    - Sets the next sink in the list as default.
    - Moves all currently playing audio streams (inputs) to the new sink.
- **Dependencies:** `pactl`, `grep`, `cut`, `bash`.

### `power-menu.sh`
**Purpose:** Displays a power management menu using `wofi`.
- **Options:** Lock, Shutdown, Reboot, Logout, Suspend.
- **Commands Used:** 
    - `hyprlock` (Lock)
    - `hyprctl dispatch exit` (Logout)
    - `systemctl` (Suspend, Reboot, Poweroff)
- **Dependencies:** `wofi`, `awk`.

### `waybar_workspaces.sh`
**Purpose:** Generates a custom JSON output for Waybar to display Hyprland workspaces.
- **Functionality:** 
    - Designed to be run per monitor (requires monitor name as an argument).
    - Filters workspaces relevant to the specific monitor.
    - Listens to the Hyprland socket via `socat` for real-time updates without polling.
    - Handles workspace offsets if configured.
    - Outputs JSON with `id`, `text` (display ID), and `class` (e.g., "active").
- **Usage:** `./waybar_workspaces.sh <monitor_name>`
- **Dependencies:** `jq`, `socat`, `hyprctl`, `grep`, `awk`.

### `wofi_notifications.sh`
**Purpose:** Displays a quick battery status popup using `wofi`.
- **Functionality:**
    - Reads battery capacity and status from `/sys/class/power_supply/`.
    - Selects an appropriate icon based on charge level and status (Charging/Full/Discharging).
    - Opens a `wofi` window in the top-right corner styled with `wofi_ncenter.css`.
- **Dependencies:** `wofi`, `cat`.

## Styles

### `wofi_ncenter.css`
**Purpose:** Provides the CSS styling for the `wofi` windows spawned by the scripts in this directory (specifically `wofi_notifications.sh`).
- **Theme:** Dark theme with Dracula-inspired colors (Background: `#282a36`, Border: `#bd93f9`).
