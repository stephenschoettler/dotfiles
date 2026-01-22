# Hyprland Keybinds Cheatsheet

**Mod Key:** `SUPER` (Windows / Command Key)

## 🚀 Applications & System
| Keybind | Action | Command |
| :--- | :--- | :--- |
| `SUPER + SPACE` | Open Terminal | `kitty` |
| `SUPER + W` | Open Browser | `brave` |
| `SUPER + E` | Open Emacs | `emacsclient -c -a "emacs"` |
| `SUPER + C` | Calculator | `qalculate-gtk` |
| `SUPER + Z` | Open File Manager | `thunar` |
| `SUPER + RETURN` | App Launcher | `wofi --show drun` |
| `SUPER + Delete` | Lock Screen | `loginctl lock-session` |
| `SUPER + Home` | Power Menu | `power-menu.sh` |
| `SUPER + N` | Notification Center | `swaync` |
| `SUPER + V` | Clipboard Manager | `cliphist_selector.sh` |
| `SUPER + Q` | Close Active Window | `killactive` |
| `SUPER + P` | Toggle Pseudo Tiling | `pseudo` |
| `SUPER + Tab` | Toggle Split | `togglesplit` |
| `SUPER + -` | Toggle Waybar | `pkill -SIGUSR1 waybar` |

## 🪟 Window Management
| Keybind | Action | Note |
| :--- | :--- | :--- |
| `SUPER + h / j / k / l` | Move Focus | Focus window (vim style) |
| `SUPER + SHIFT + F` | Toggle Fullscreen | |
| `SUPER + F` | Toggle Floating | Center & Resize (90%) |
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
| `SUPER + CTRL + 0-9` | Swap Specific Workspace Pair (Monitor Handling) |

## 📸 Screenshots (Hyprshot)
| Keybind | Action | Output Destination |
| :--- | :--- | :--- |
| `Print` | Monitor Screenshot | `~/pictures/screenshots` |
| `SUPER + Print` | Region Screenshot | `~/pictures/screenshots` |
| `SUPER + CTRL + Print` | Region Screenshot | Clipboard |

## 🔊 Hardware & Media
| Keybind | Action |
| :--- | :--- |
| `Volume Up (Key)` | Volume +5% |
| `Volume Down (Key)` | Volume -5% |
| `Mute (Key)` | Toggle Mute |
| `Brightness Up (Key)` | Brightness +10% |
| `Brightness Down (Key)` | Brightness -10% |
| `Media Keys` | Play/Pause/Next/Prev |