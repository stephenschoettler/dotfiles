# Dotfiles

Personal configuration files for two Arch Linux machines, managed with a unified install script.

## Machines

| Host | Role | Hardware |
|------|------|----------|
| **slim5** | Desktop (Hyprland) | Ryzen 7 7840HS · RTX 4060 · 32GB RAM |
| **w0lf-mini** | Headless server | Intel N100 · 16GB RAM |

## What's Included

| Directory | Description | slim5 | w0lf-mini |
|-----------|-------------|:-----:|:---------:|
| `shell/` | Zsh config & aliases | ✔ | ✔ |
| `eza/` | eza (ls replacement) config | ✔ | ✔ |
| `tmux/` | Tmux — full desktop config + minimal server variant | ✔ | ✔\* |
| `hypr/` | Hyprland window manager | ✔ | — |
| `kitty/` | Kitty terminal | ✔ | — |
| `waybar/` | Waybar status bar (Dracula theme) | ✔ | — |
| `cava/` | CAVA audio visualizer | ✔ | — |
| `pikaur/` | Pikaur AUR helper | ✔ | — |
| `nvim/` | Neovim config | manual | manual |
| `wallpaper/` | Wallpapers (Dracula themed) | ✔ | — |

\* w0lf-mini uses `tmux/tmux-server.conf` — same keybindings, no GPU/desktop status scripts.

## Install

```bash
git clone https://github.com/stephenschoettler/dotfiles.git
cd dotfiles
./install.sh
```

The script detects the hostname (`slim5` or `w0lf-mini`) and symlinks the appropriate configs. Existing files are backed up to `*.bak`.

## Design Notes

- **Tmux keybindings** mirror Hyprland (`Alt+h/j/k/l` for navigation) for muscle-memory consistency.
- **Dracula** color scheme throughout (Hyprland, Waybar, Kitty, Tmux).
- Server config is intentionally minimal — shell, eza, and tmux only.

## License

[GPL](LICENSE)
