#!/bin/bash
# install.sh — Symlink dotfiles into place
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        warn "Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    info "Linked $dst → $src"
}

echo "Installing dotfiles from $DOTFILES"
HOSTNAME=$(hostname)
echo "Detected hostname: $HOSTNAME"
echo ""

# Shell (all machines)
link "$DOTFILES/shell/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES/shell/.aliases" "$HOME/.aliases"

# Common configs (all machines)
for dir in eza pikaur; do
    link "$DOTFILES/$dir" "$HOME/.config/$dir"
done

# Desktop-only configs (slim5)
if [[ "$HOSTNAME" == "slim5" ]]; then
    info "Desktop mode: linking Hyprland, Waybar, Kitty, Cava..."
    for dir in hypr kitty waybar cava; do
        link "$DOTFILES/$dir" "$HOME/.config/$dir"
    done
    link "$DOTFILES/tmux" "$HOME/.config/tmux"
fi

# Server configs (w0lf-mini)
if [[ "$HOSTNAME" == "w0lf-mini" ]]; then
    info "Server mode: linking minimal configs..."
    mkdir -p "$HOME/.config/tmux"
    link "$DOTFILES/tmux/tmux-server.conf" "$HOME/.config/tmux/tmux.conf"
fi

echo ""
info "Done! Restart your shell or run 'source ~/.zshrc'"
