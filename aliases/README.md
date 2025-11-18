## Aliases Cheat Sheet

### Bash
* `reload`: `source ~/.zshrc`  
  Reloads your Zsh configuration without restarting the shell.

### Navigation
* `..`: `cd ..`  
  Go up one directory.
* `...`: `cd ../..`  
  Go up two directories.
* `....`: `cd ../../..`  
  Go up three directories.

### Terminal
* `c`: `clear && colorscript --exec crunchbang-mini`  
  Clears the terminal and runs a colorscript banner.

### History
* `h`: `history | tail -10`  
  Show the last 10 commands.
* `hc`: `history -c`  
  Clear history.
* `r`: `!!`  
  Repeat the last command.
* `hr`: `!`  
  Run a command by history number.
* `hgrep`: `history | grep`  
  Search command history.

### Core Directory Views
* `ls`: `exa --icons`  
  File listing with icons.
* `l`: `exa -a --icons`  
  Show hidden files with icons.
* `ll`: `exa -la --icons`  
  Long list format with icons.
* `l1`: `exa -1 --icons`  
  One entry per line with icons.
* `lh`: `exa -lh --icons`  
  Human-readable sizes with icons.
* `lhd`: `exa -lhD --icons`  
  Show directories only with human-readable sizes.

### Tree Views
* `lt`: `exa -T --icons`  
  Show directory tree.
* `lt1`: `exa -T --level=1 --icons`  
  Tree view up to depth 1.
* `lt2`: `exa -T --level=2 --icons`  
  Tree view up to depth 2.
* `lt3`: `exa -T --level=3 --icons`  
  Tree view up to depth 3.

### Sorting Variants
* `lsn`: `exa -l --sort=newest --icons`  
  Sort by newest files.
* `lso`: `exa -l --sort=oldest --icons`  
  Sort by oldest files.
* `lss`: `exa -l --sort=size --icons`  
  Sort by file size.
* `lse`: `exa -l --sort=extension --icons`  
  Sort by file extension.

### Git Integration
* `lg`: `exa -l --git --icons`  
  Long list with git status.
* `lga`: `exa -la --git --icons`  
  Show all files with git status.

### Permission Details
* `lo`: `exa -l --octal-permissions --icons`  
  Show octal permissions.
* `loh`: `exa -lh --octal-permissions --icons`  
  Octal permissions with human-readable sizes.

### Brightness
* `brightness_max`: `xrandr --output DP-2 --brightness 1.0 && echo "Brightness set to 100%"`  
  Set screen brightness to 100%.
* `brightness_set <value>`  
  Set brightness to a specific value (0.1–1.0).
* `brightness_up`  
  Increase brightness by 0.1.
* `brightness_down`  
  Decrease brightness by 0.1.

### Misc
* `fetch`: `neofetch`  
  Display system information.
* `top`: `btop`  
  Launch the `btop` system monitor.
* `ping`: `ping -c 5`  
  Send 5 pings by default.

### OpenCode
* `ask`: `opencode run --model openrouter/google/gemini-2.0-flash-exp:free`  
  Run an AI query with Gemini via OpenCode.

### Pikaur
* `pi`: `pikaur -Syu`  
  Update system and AUR packages.
* `pis`: `pikaur -Ss`  
  Search for packages.
* `pii`: `pikaur -S`  
  Install a package.
* `pir`: `pikaur -R`  
  Remove a package.
* `pirn`: `pikaur -Rns`  
  Remove with dependencies and configs.
* `piu`: `pikaur -Sua`  
  Update only AUR packages.
* `pic`: `pikaur -Sc`  
  Clean package cache.
* `pio`: `pikaur -Qdt`  
  List orphaned packages.
* `pior`: `pikaur -Rns $(pikaur -Qdtq)`  
  Remove orphaned packages.
* `piq`: `pikaur -Q`  
  Query installed packages.
* `pia`: `pikaur -Qm`  
  List manually installed packages.
* `pinfo`: `pikaur -Qi`  
  Show package information.
* `pil`: `pikaur -Ql`  
  List package files.
* `pid`: `pikaur -R $(pikaur -Qdtq)`  
  Remove detected orphans.
* `pidown`: `pikaur -Sw`  
  Download package files only.
* `pie`: `pikaur --edit`  
  Edit PKGBUILD before install.
* `piout`: `pikaur -Qum`  
  List outdated packages.
* `pdep`: `pikaur -Si`  
  Show dependency info.

### Plex Sync
* `rsmovies <source>`: `rsync -avh --progress <source> w0lf@192.168.68.66:/mnt/media/Movies/`  
  Sync movies to Plex server.
* `rstv <source>`: `rsync -avh --progress <source> w0lf@192.168.68.66:/mnt/media/TV/`  
  Sync TV shows to Plex server.
