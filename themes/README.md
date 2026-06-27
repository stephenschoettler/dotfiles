# Hyprland theme system

This repo uses explicit named theme manifests, not a dynamic rice engine. The active theme is rendered into small generated fragments consumed by Hyprland and the desktop apps.

## Layout

- `themes/<name>/theme.json` - human-edited source of truth for wallpaper, colors, and small per-theme settings.
- `themes/current` - generated active theme name.
- `bin/hypr-theme` - switch/list/doctor command.
- Generated active files:
  - `hypr/theme.conf` - Hyprland border/decoration tokens.
  - `hypr/hyprpaper.conf` - wallpaper config for hyprpaper.
  - `hypr/hyprlock.conf` - rendered from `hypr/hyprlock.base.conf` plus theme tokens.
  - `waybar/colors.css` - Waybar color tokens.
  - `swaync/theme.css` - SwayNC color tokens imported by `swaync/style.css`.
  - `wofi/theme.css` - Wofi color tokens imported by `wofi/style.css`.
  - `kitty/theme.conf` - Kitty color/theme include.

## Switching

From the dotfiles repo:

```sh
bin/hypr-theme list
bin/hypr-theme apply dracula
bin/hypr-theme apply sailor
```

`apply` renders the active files, records `themes/current`, sets the wallpaper through `hyprpaper` IPC when Hyprland is running, asks Hyprland to reload, reloads SwayNC CSS/config, and sends `SIGUSR2` to Waybar. Kitty, Wofi, and Hyprlock pick up the generated files on next launch.

If you only want to render files without touching the live desktop:

```sh
bin/hypr-theme apply dracula --no-reload
```

Run this after checkout/install to verify live config is actually linked to this repo:

```sh
bin/hypr-theme doctor
```

On slim5, `install.sh` links the desktop config directories into `~/.config`. If `doctor` warns that a live config dir is not linked to this repo, switching will still update this worktree but the running desktop may not consume every generated file until the dotfiles are installed/linked.

## Adding a theme

1. Create `themes/<name>/theme.json` by copying an existing manifest.
2. Put any wallpaper asset under `wallpaper/` and set the manifest `wallpaper` path relative to the repo root.
3. Adjust color tokens. Keep required keys present; `bin/hypr-theme doctor` validates them.
4. Test render-only first: `bin/hypr-theme apply <name> --no-reload`.
5. Apply live: `bin/hypr-theme apply <name>`.

## Wallpaper transitions

Deferred. `awww` is not installed on this workstation during this implementation, while `hyprpaper` is installed, running, and supports direct IPC updates. The architecture keeps wallpaper ownership in the manifest and centralizes wallpaper application in `bin/hypr-theme`, so a later `awww` backend can be added without changing the theme format or spreading transition logic through app configs.
