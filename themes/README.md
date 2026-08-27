# Hyprland theme system

This repo uses explicit named theme manifests, not a dynamic rice engine. The active theme is rendered into small generated fragments consumed by Hyprland and the desktop apps.

## Layout

- `themes/<name>/theme.json` - human-edited source of truth for wallpaper, colors, and small per-theme settings.
- `themes/current` - generated active theme name.
- `bin/hypr-theme` - switch/list/doctor command.
- Generated active files:
  - `hypr/theme.lua` - Hyprland border/decoration tokens loaded by `hyprland.lua`.
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

If Hyprland is using the repo-linked config on slim5, you can open a fuzzel theme picker with `Super+Shift+Return` and a transition-origin preset picker with `Super+Ctrl+Return`. The theme menu annotates the active row as `[current | <preset>]`, and theme-switch notifications also report the active transition preset so you always know what mode the next switch will use.

`apply` renders the active files, records `themes/current`, then updates the wallpaper backend before reloading the rest of the desktop. On slim5 it now prefers `awww` for animated transitions and falls back to `hyprpaper` if `awww` is unavailable. Kitty, Wofi, and Hyprlock pick up the generated files on next launch.

Per-theme wallpaper motion lives in `wallpaper_transition`, while the global origin override lives in `themes/transition-preset`. The current default preset is `cursor`, so the `grow` transition expands from the live mouse position instead of a fixed corner unless you deliberately switch presets.

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

Enabled. `awww` is installed on slim5 and is now the preferred wallpaper backend for animated transitions, while `hyprpaper` remains as the fallback path if `awww` is unavailable. The architecture still keeps wallpaper ownership in the manifest and centralizes wallpaper application in `bin/hypr-theme`, so changing transition style is a theme-data change rather than an app-by-app rewrite.
