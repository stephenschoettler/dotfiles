# Waybar Configuration

This is a highly customized [Waybar](https://github.com/Alexays/Waybar) configuration designed for **Hyprland**. It features a **Dracula** theme, per-monitor workspaces, and various interactive modules.

## Overview

- **Theme:** [Dracula](https://draculatheme.com/) (Dark background with Pink/Purple accents).
- **Font:** JetBrainsMono Nerd Font.
- **Position:** Top bar.
- **Compositor:** Hyprland.

## Features

- **Multi-Monitor Support:**
  - Dedicated configuration for Laptop (`eDP-2`) vs External Monitors (`DP-1`, `HDMI-A-1`).
  - Custom workspace handling for each output.
- **Modules:**
  - **Workspaces:** Kanji numeral representation (一, 二, 三...) with active/urgent/empty states.
  - **Window Title:** Intelligent rewriting for common apps (Firefox, VS Code, Discord, Emacs, Brave) to show icons.
  - **Audio:** PulseAudio control with scroll-to-change volume and right-click to cycle audio sinks (Speaker/Headphones).
  - **Backlight:** Brightness control with scroll support.
  - **Battery:** Detailed status icons and percentage.
  - **Clock:** Date/Time with hoverable calendar.
  - **Notifications:** Integrated with `swaync` (SwayNotificationCenter).
  - **Power Menu:** Custom `wofi` based power menu (Lock, Sleep, Shutdown, etc.).
  - **Idle Inhibitor:** One-click toggle to prevent screen sleep.

## Dependencies

Ensure you have the following installed for all modules to function correctly:

- **Waybar**: The bar itself.
- **Hyprland**: For workspace and window information.
- **Nerd Fonts**: Specifically `JetBrainsMono Nerd Font` for icons.
- **Audio**: `pulseaudio` (or PipeWire with `pipewire-pulse`), `pactl`, `pamixer`.
- **Backlight**: `intel_backlight` (or compatible driver).
- **Notifications**: `swaync` (SwayNotificationCenter).
- **Menus/Launcher**: `wofi`.
- **Utils**: `jq`, `socat` (used by helper scripts).

## Configuration Files

- **`config`**: The main JSON configuration defining modules and layout.
- **`style.css`**: The core stylesheet.
- **`colors.css`**: Dracula color variables.
- **`dracula.json`**: JSON reference for the color palette.
- **`scripts/`**: [Helper scripts](./scripts/README.md) for audio, power menu, and custom logic.

## Installation

1.  Clone this repository or copy the files to `~/.config/waybar/`.
2.  Ensure dependencies are installed.
3.  Reload Waybar (usually auto-reloads on config change, or `killall waybar && waybar`).

## Module Highlights

### Workspaces
Customized to show specific ranges or icons based on the monitor.
- **Laptop:** Shows workspaces with Kanji icons.
- **External:** Configured for a separate workspace range.

### Interactive Elements
- **Volume:** Scroll up/down on the volume icon to change volume. Right-click to switch audio output devices.
- **Power:** Click the power icon to open the Wofi power menu.
- **Notifications:** Click the bell icon to toggle the notification center.

## Credits
- **Theme:** Based on the [Dracula Theme](https://draculatheme.com/).
