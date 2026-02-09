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
echo ""

# Shell
link "$DOTFILES/shell/.zshrc"   "$HOME/.zshrc"
link "$DOTFILES/shell/.aliases" "$HOME/.aliases"

# XDG configs (~/.config/*)
for dir in hypr kitty tmux waybar nvim cava eza pikaur; do
    link "$DOTFILES/$dir" "$HOME/.config/$dir"
done

echo ""
info "Done! Restart your shell or run 'source ~/.zshrc'"
