# ~/.zshrc — Cyberpunk Wireframe Edition (Merged)

# --------------------------
# 1. PATH & EDITOR
# --------------------------
export EDITOR=nvim 
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# CUDA
export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"

# ROCm (Cleaned up - added once)
export PATH=$PATH:/opt/rocm/bin

# --------------------------
# 2. OH MY ZSH FRAMEWORK
# --------------------------
export ZSH="$HOME/.oh-my-zsh"

# Note: We disable Powerlevel10k here so the Cyberpunk Wireframe 
# prompt can take over. If you want p10k back, uncomment the next line.
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="" 

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# --------------------------
# 3. BASIC CONFIG
# --------------------------
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
HIST_STAMPS="mm/dd/yyyy"

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# --------------------------
# 4. ALIASES & FUNCTIONS
# --------------------------
[[ -f ~/.aliases ]] && source ~/.aliases
alias cat='bat --paging=never'
alias t='tmux'
alias ta='tmux attach'

# LMStudio Function
unalias lmstudio 2>/dev/null
lmstudio() {
  local appimage version
  appimage=$(find "$HOME" -maxdepth 1 -type f -name "LM-Studio-*-x64.AppImage" | sort | tail -n 1)

  if [[ -z "$appimage" ]]; then
    echo "❌ Error: LM Studio AppImage not found in $HOME"
  else
    version=$(basename "$appimage" | sed -E 's/LM-Studio-([0-9.]+)-.*/\1/')
    nohup "$appimage" > "$HOME/lmstudio.log" 2>&1 & disown
    echo "✅ Launched LM Studio version $version"
  fi
}

# Lazy-load Conda
conda() {
  unset -f conda
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
  conda "$@"
}

# FZF Support
source <(fzf --zsh)

# Command Capture
[[ -f ~/.config/command-capture/command-capture.zsh ]] && source ~/.config/command-capture/command-capture.zsh

# --------------------------
# 5. CYBERPUNK WIREFRAME VISUALS (FINAL v3)
# --------------------------

# --- GRAVITY: Force prompt to bottom ---

# 1. The Function: Dumb and effective
function clear-to-bottom() {
    # Print 100 empty lines to force the scrollbar down immediately.
    # We don't rely on 'tput lines' because Tmux geometry can lag on startup.
    yes "" | head -n 100
    
    # \033[2J   = Clear screen
    # \033[H    = Home cursor
    # \033[999B = Move down 999 lines
    printf "\033[2J\033[H\033[999B"
    
    # Reset the prompt if the line editor is active
    if [[ -n "$ZLE_STATE" ]]; then
        zle .reset-prompt
    fi
}

# 2. Register Widget & Bindings
zle -N clear-to-bottom
bindkey '^l' clear-to-bottom
alias clear='clear-to-bottom'

# 3. STARTUP TRIGGER
# We removed the 'if' check. Now it runs on EVERY interactive shell start.
if [[ -n "$TMUX" ]]; then
    clear-to-bottom
fi

# --- ENVIRONMENT CONFIG ---
export VIRTUAL_ENV_DISABLE_PROMPT=1

function venv_info() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "─[ %F{#8be9fd}venv:$(basename $VIRTUAL_ENV)%F{#50fa7b} ]"
    fi
}

# --- GIT CONFIG ---
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '─[ %F{#f1fa8c}git:%b%F{#50fa7b} ]'

# --- PROMPT DESIGN ---
setopt PROMPT_SUBST

P_GREEN='%F{#50fa7b}'
P_WHITE='%F{#f8f8f2}'
P_ORANGE='%F{#ffb86c}'
P_RESET='%f'

# Structure: 
# ┌─[ user ]─[ dir ]─[ git ]─[ venv ]
# ─>>
PROMPT='${P_GREEN}┌─[ ${P_WHITE}%n@%m ${P_GREEN}]─[ ${P_ORANGE}%~ ${P_GREEN}]${vcs_info_msg_0_}$(venv_info)
${P_GREEN}└─>>${P_RESET} '

# --------------------------
# 6. SAFE TMUX AUTOSTART (Last)
# --------------------------
# Autostart tmux only for interactive, non-root, real TTY, not inside tmux, not VS Code
case $- in *i*) _interactive=1;; esac
if [[ -z "$TMUX" && -n "$_interactive" && -t 1 && -z "$VSCODE_PID" && "$EUID" -ne 0 && "${TMUX_AUTO:-1}" = 1 ]]; then
  if command -v tmux >/dev/null 2>&1; then
    _name="${TMUX_SESSION_NAME:-main}"
    tmux has-session -t "$_name" 2>/dev/null && tmux attach -t "$_name" || tmux new -s "$_name"
  fi
fi
unset _interactive

# --------------------------
# 6. TRANSIENT PROMPT (Clean History)
# --------------------------
# 1. Define the "transient" (mini) prompt
# Simplified: Just the arrow, no corner.
TRANSIENT_PROMPT='${P_GREEN}─>>${P_RESET} '

# 2. Widget to switch to mini prompt when command is accepted
function set-transient-prompt {
    emulate -L zsh
    # Swap to the mini prompt immediately
    PROMPT="${TRANSIENT_PROMPT}"
    # Redraw the prompt to lock the mini version into history
    zle reset-prompt
}

# 3. Register the widget correctly
zle -N zle-line-finish set-transient-prompt

# 4. Restore full prompt before the NEXT command prompt is drawn
autoload -Uz add-zsh-hook

function restore-full-prompt {
    # Update Git info
    vcs_info
    
    # Restore the full Wireframe Prompt
    PROMPT='${P_GREEN}┌─[ ${P_WHITE}%n@%m ${P_GREEN}]─[ ${P_ORANGE}%~ ${P_GREEN}]${vcs_info_msg_0_}$(venv_info)
${P_GREEN}└─>>${P_RESET} '
}

# Safely add this to the precmd list
add-zsh-hook precmd restore-full-prompt
