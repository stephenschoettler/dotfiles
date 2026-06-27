## Tmux Cheat Sheet - Sessions, Windows, and Panes

**Prefix key:** Alt+a (press Alt and a together)
- `Alt+a Alt+a`: Allow nested sessions
- Case matters: `Alt+a s` and `Alt+a S` are different bindings.

### Sessions

- `tmux new`: Start a new session
- `tmux new -s <session-name>`: Start a new session with a specific name
- `tmux ls`: List all sessions
- `Alt+a s`: Show all sessions in the default tmux chooser/tree view
- `tmux a`: Attach to the last used session
- `tmux a -t <session-name>`: Attach to a specific session
- `Alt+a :`: Rename the current session via the command prompt
- `Alt+a d`: Detach from the current session
- `tmux kill-session -t <session-name>`: Kill a specific session

### Reload Config
- `Alt+a r`: Reload tmux config and display confirmation

### Windows

- `Alt+a c`: Create a new window in the current pane directory (runs color-window hook)
- `Alt+n`: Fast create a new window in the current pane directory (no prefix)
- `Alt+a ,`: Rename the current window
- `Alt+x`: Kill the current window (no prefix)
- `Alt+a &`: Kill the current window with confirmation
- `Alt+a w`: Show windows in the default tmux chooser/tree view
- `Alt+a <number>`: Switch to window by number (1-9)
- `Alt+a h` / `Alt+a l`: Switch to previous/next window
- `Alt+a a`: Toggle last active window
- `Alt+1` .. `Alt+9`: Jump directly to windows 1-9 (no prefix)
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
- `Alt+Left` / `Alt+Right` / `Alt+Up` / `Alt+Down`: Move focus between panes
- `Alt+h/j/k/l`: Move focus between panes
- `Ctrl+h/j/k/l`: Move focus between panes, passing through to Vim/Neovim when active
- `Alt+Ctrl+h/j/k/l`: Move the current pane in that direction
- `Alt+a S`: Toggle synchronized input across actual split panes in the current window

### Chooser vs Synchronized Panes

- `Alt+a s`: Session chooser/tree. The boxed previews are normal tmux UI, not pane sync.
- `Alt+a w`: Window chooser/tree. Also default tmux UI.
- `Alt+a S`: Synchronized panes toggle. Only affects the current window's real split panes; it does not create panes or change the layout.
- Use `Alt+a S` again to turn synchronized input back off.

### Copy Mode

- `Alt+a [`: Enter copy mode
- `Alt+a /` or `Alt+a Ctrl+f`: Search the active pane's visible output/scrollback, starting upward from the current prompt
- After a search: `n` jumps to the next match, `N` jumps in the opposite direction, `q` exits copy/search mode
- Search scope is the active pane only. Focus another pane first to search that pane.
- `y` or `Enter`: Copy the selection; uses `wl-copy` when available, otherwise tmux buffer only

### Popups

- `Alt+a t`: Show 12hr clock + date popup
- `Alt+a p`: Open fzf project/session switcher
- `Alt+a B`: Open btop popup

### Status Bar (Dracula Theme)

- Updates every 5 seconds with a bottom-aligned bar
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
  - `tmux-cpu` (CPU and RAM format variables)

### Session Restore

- `tmux-resurrect` and `tmux-continuum` are configured for 15-minute autosaves and restore-on-start.
