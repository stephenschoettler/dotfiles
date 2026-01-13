# Hyprland Keybinds Cheatsheet

**Mod Key:** `SUPER` (Windows / Command Key)

## 🚀 Applications & System
| Keybind | Action | Command |
| :--- | :--- | :--- |
| `SUPER + SPACE` | Open Terminal | `kitty` |
| SUPER + W | Open Browser | `brave` |
| SUPER + E | Open Emacs | `emacs` |
| SUPER + C | Calculator | `qalculate-gtk` |
| `SUPER + Z` | Open File Manager | `thunar` |
| `SUPER + RETURN` | App Launcher | `wofi --show drun` |
| `SUPER + Escape` | Lock Screen | `hyprlock` |
| `SUPER + Q` | Close Active Window | `killactive` |
| `SUPER + X` | Toggle Pseudo Tiling | `pseudo` |
| `SUPER + \|` | Toggle Split | `togglesplit` |
| `SUPER + -` | Toggle Waybar | `pkill -SIGUSR1 waybar` |

## 🪟 Window Management
| Keybind | Action | Note |
| :--- | :--- | :--- |
| `SUPER + h / j / k / l` | Move Focus | Focus window (vim style) |
| `SUPER + SHIFT + F` | Toggle Fullscreen | |
| `SUPER + SHIFT + W` | Toggle Floating | |
| `SUPER + SHIFT + h / j / k / l` | Resize Window | Resize by 10px |
| `SUPER + ALT + h / j / k / l` | Move Window (Floating) | Move by 10px |
| `SUPER + CTRL + h / j / k / l` | Move Window (Layout) | Move window in direction |
| `SUPER + LMB (Drag)` | Move Window | Mouse drag |
| `SUPER + RMB (Drag)` | Resize Window | Mouse drag |

## 🖥️ Workspaces
| Keybind | Action |
| :--- | :--- |
| `SUPER + 0-9` | Switch to Workspace 1-10 |
| `SUPER + SHIFT + 0-9` | Move Active Window to Workspace 1-10 |
| `SUPER + Scroll` | Cycle Through Workspaces |
| `SUPER + S` | Swap Workspaces Between Monitors |
| `SUPER + CTRL + 0-9` | Swap Specific Workspace Pair (Monitor Handling) |

## 📸 Screenshots (Hyprshot)
| Keybind | Action | Output Destination |
| :--- | :--- | :--- |
| `Print` | Region Screenshot | `~/Pictures/Screenshots` |
| `SUPER + CTRL + Print` | Region Screenshot | Clipboard |
| `SUPER + Print` | Full Screen Screenshot | `~/Pictures/Screenshots` |

## 🔊 Hardware & Media
| Keybind | Action |
| :--- | :--- |
| `Volume Up (Key)` | Volume +5% |
| `Volume Down (Key)` | Volume -5% |
| `Mute (Key)` | Toggle Mute |
| `Brightness Up (Key)` | Brightness +10% |
| `Brightness Down (Key)` | Brightness -10% |
