# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------------------------
# Basic Completion & History
# --------------------------
autoload -Uz compinit
compinit

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
HIST_STAMPS="mm/dd/yyyy"

# --------------------------
# Editor & PATH
# --------------------------
export EDITOR=nvim 
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# --------------------------
# Oh My Zsh Framework
# --------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
#PROMPT='%n@%m %# '

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# --------------------------
# UI Enhancements
# --------------------------
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# --------------------------
# CUDA (safe to always add)
# --------------------------
export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"

# --------------------------
# Safe tmux autostart
# --------------------------

# Autostart tmux only for interactive, non-root, real TTY, not inside tmux, not VS Code
case $- in *i*) _interactive=1;; esac
if [[ -z "$TMUX" && -n "$_interactive" && -t 1 && -z "$VSCODE_PID" && "$EUID" -ne 0 && "${TMUX_AUTO:-1}" = 1 ]]; then
  if command -v tmux >/dev/null 2>&1; then
    # Optional: per-host session name, defaults to "main"
    _name="${TMUX_SESSION_NAME:-main}"
    # Attach if exists, otherwise create it
    tmux has-session -t "$_name" 2>/dev/null && tmux attach -t "$_name" || tmux new -s "$_name"
  fi
fi
unset _interactive

# --------------------------
# RANDOM COLOR SCRIPT
# --------------------------
#if [[ "$-" == *i* ]]; then
#    colorscript --exec crunchbang-mini
#fi

# --------------------------
# Aliases
# --------------------------
[[ -f ~/.aliases ]] && source ~/.aliases

# --------------------------
# Command Capture
# --------------------------
[[ -f ~/.config/command-capture/command-capture.zsh ]] && source ~/.config/command-capture/command-capture.zsh

# --------------------------
# LMStudio
# -------------------------
unalias lmstudio 2>/dev/null
lmstudio() {
  local appimage version
  appimage=$(find "$HOME" -maxdepth 1 -type f -name "LM-Studio-*-x64.AppImage" | sort | tail -n 1)

  if [[ -z "$appimage" ]]; then
    echo "❌ Error: LM Studio AppImage not found in $HOME"
  else
    # Extract version from filename using pattern matching
    version=$(basename "$appimage" | sed -E 's/LM-Studio-([0-9.]+)-.*/\1/')
    nohup "$appimage" > "$HOME/lmstudio.log" 2>&1 & disown
    echo "✅ Launched LM Studio version $version"
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#
# Lazy-loads Conda to speed up shell startup.
#
# The 'conda' command is initially a function. The first time it's run,
# it unsets itself, runs the real conda initialization, and then
# executes the command the user originally typed. Subsequent calls
# go directly to the real conda command.
#
conda() {
  # Unset this function so it's not called again
  unset -f conda

  # Run the actual, slow conda initialization
  # This is the line that was slowing down your shell
  __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
          . "/opt/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="/opt/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup

  # Now that conda is initialized, run the command the user wanted
  conda "$@"
}

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)


alias cat='bat --paging=never'

export PATH="$HOME/.npm-global/bin:$PATH"export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
echo 'export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1' >> ~/.zshrcexport CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

#export STARSHIP_CONFIG=~/.config/starship/starship.toml
#eval "$(starship init zsh)"

echo 'export PATH=$PATH:/opt/rocm/bin' >> ~/.zshrc
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
export PATH=$PATH:/opt/rocm/bin
