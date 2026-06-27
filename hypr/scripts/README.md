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
**Description:** Sends the focused window to the requested workspace slot on the other monitor.

**Logic:**
- Key `N` maps to pair `N`/`N+10` (`0` maps to `10`/`20`).
- In dual-monitor mode, if the window is on the monitor currently owning slot `N`, it moves to slot `N+10`; if it is on the monitor owning `N+10`, it moves to slot `N`.
- Uses live workspace placement, so global workspace swaps are honored.
- In laptop-only mode, it falls back to the base workspace so windows stay reachable.

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

### `screenshot.sh`
**Description:** Unified screenshot workflow using `grim`/`slurp` with runtime monitor detection and optional `swappy` annotation.

**Usage:**
- `./screenshot.sh output focused`
- `./screenshot.sh output laptop`
- `./screenshot.sh output external`
- `./screenshot.sh region`
- `./screenshot.sh clipboard`
- `./screenshot.sh edit`

### `screenshot_output.sh`
**Description:** Backwards-compatible wrapper around `screenshot.sh output`.

**Usage:**
- `./screenshot_output.sh focused`
- `./screenshot_output.sh laptop`
- `./screenshot_output.sh external`

## Other scripts

### `cliphist_selector.sh`
**Description:** Launches a Fuzzel/Dracula-styled clipboard history selector using `cliphist`.
**Behavior:** Includes a clear-history row with a second confirmation before `cliphist wipe`, and shows only the most recent entries by default so the menu opens quickly.
**Tuning:** `CLIPHIST_SELECTOR_LIMIT` defaults to `200`; `CLIPHIST_SELECTOR_PREVIEW_WIDTH` defaults to `140`.
**Dependencies:** `awk`, `cliphist`, `fuzzel`, `wl-clipboard`

### `osd_control.sh`
**Description:** Volume, mute, brightness, and media-key wrapper. Uses SwayOSD when installed and falls back to `wpctl`, `brightnessctl`, and `playerctl`.
By default it lets SwayOSD render on all monitors, which avoids the current Hyprland/SwayOSD `--monitor` placement quirk on this machine. Set `OSD_MONITOR_MODE=focused` or a monitor name to opt into explicit SwayOSD monitor targeting.

### `night_light.sh`
**Description:** Toggles Hyprsunset blue-light filtering and exposes a JSON status payload for Waybar.

### `desktop_health.sh`
**Description:** PASS/FAIL smoke check for Hyprland, Waybar, SwayNC, Fuzzel, scripts, live/dotfiles sync, and required desktop processes.

### `start_swayosd.sh`, `start_hyprsunset.sh`, `start_polkit_agent.sh`
**Description:** Safe autostart wrappers that no-op or fall back when optional packages are missing.

### `lock_status.sh`
**Description:** Outputs the subtle Hyprlock metadata row: user, host, and battery status when a battery is present.

### `render_hyprlock_clock.py`
**Description:** Renders the Hyprlock clock as a transparent PNG using rectangle-drawn block glyphs. This avoids Pango/font seams in Unicode block characters.

### `lock_screen.sh`
**Description:** Pre-renders the Hyprlock clock PNG before launching `hyprlock`, so the lock screen does not start with a stale clock image.

### `get_ascii_time.sh`
**Description:** Legacy text/Pango 3-line ASCII time generator retained as a fallback; Hyprlock now uses `render_hyprlock_clock.py` via an `image` widget.

### `greeting.sh`
**Description:** Outputs a simple greeting message for status bars or lock screens.
