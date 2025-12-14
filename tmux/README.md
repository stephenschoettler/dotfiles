## Tmux Cheat Sheet - Sessions, Windows, and Panes

**Prefix key:** Alt+a (press Alt and a together)
- `Alt+a Alt+a`: Allow nested sessions

### Sessions

- `tmux new`: Start a new session
- `tmux new -s <session-name>`: Start a new session with a specific name
- `tmux ls`: List all sessions
- `Alt+a s`: Show all sessions (interactive)
- `tmux a`: Attach to the last used session
- `tmux a -t <session-name>`: Attach to a specific session
- `Alt+a :`: Rename the current session via the command prompt
- `Alt+a d`: Detach from the current session
- `tmux kill-session -t <session-name>`: Kill a specific session

### Reload Config
- `Alt+a r`: Reload tmux config and display confirmation

### Windows

- `Alt+a c`: Create a new window (runs color-window hook)
- `Alt+n`: Fast create a new window (no prefix)
- `Alt+a ,`: Rename the current window
- `Alt+x`: Kill the current window (no prefix)
- `Alt+a &`: Kill the current window with confirmation
- `Alt+a w`: List windows (interactive)
- `Alt+a <number>`: Switch to window by number (1-9)
- `Alt+a l`: Toggle last active window
- `Alt+h` / `Alt+l`: Switch windows without prefix
- `Alt+1` .. `Alt+9`: Jump directly to windows 1-9 (no prefix)
- `Alt+q` .. `Alt+o`: Fallback jump to windows 1-9 for terminals that steal Alt+digits
- `Alt+Shift+h` / `Alt+Shift+l`: Swap current window with previous/next window

### Panes

- `Alt+a |`: Split pane right (vertical split)
- `Alt+a -`: Split pane below (horizontal split)
- `Alt+a z`: Toggle pane zoom (maximize/restore)
- `Alt+a x`: Kill the current pane
- `Alt+a q`: Show pane numbers
- `Alt+a [`: Enter copy mode (vi keys)
- `Alt+a ]`: Paste contents of the buffer
- `Alt+a H/J/K/L`: Resize the current pane by 5 cells (hold Shift for uppercase)
- `Alt+Left` / `Alt+Right` / `Alt+Up` / `Alt+Down`: Move focus between panes (smart with Vim)

### Popups

- `Alt+a t`: Show 12hr clock + date popup

### Status Bar (Dracula Theme)

- Updates every second with a bottom-aligned bar
- Left side shows session name with Dracula colors
- Right side shows prefix status plus CPU, RAM, and GPU info (`gpu-status.sh`)
- Window tabs styled with Dracula colors for active/inactive states

### Plugins

- TPM (`prefix` + `I` to install) with:
  - `tmux-sensible`
  - `vim-tmux-navigator`
  - `tmux-resurrect`
  - `tmux-continuum`
  - `tmux-yank`
  - `tmux-prefix-highlight`
  - `tmux-cpu`
  - `tmux-ram`
