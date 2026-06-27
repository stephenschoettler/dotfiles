#!/usr/bin/env bash
set -euo pipefail

if ! command -v fzf >/dev/null 2>&1; then
  tmux display-message "fzf not found"
  exit 0
fi

project_list() {
  if [ -d "$HOME/dev" ]; then
    find "$HOME/dev" \
      -mindepth 1 -maxdepth 2 \
      \( -name .git -o -name node_modules -o -name .venv -o -name __pycache__ \) -prune -o \
      -type d -print
  fi

  for dir in "$HOME" "$HOME/.config" "$HOME/.hermes"; do
    [ -d "$dir" ] && printf '%s\n' "$dir"
  done
}

session_name_for_path() {
  local path="$1"
  local name

  case "$path" in
    "$HOME/dev"/*) name=${path#"$HOME/dev"/} ;;
    *) name=$(basename "$path") ;;
  esac

  name=$(printf '%s' "$name" | tr '/.' '__' | tr -c 'A-Za-z0-9_-' '_' | sed 's/^_*//; s/_*$//; s/__*/_/g')
  [ -n "$name" ] || name="project"
  printf '%s' "${name:0:80}"
}

project=$(project_list | awk '!seen[$0]++' | sort | fzf --prompt='project> ' --height=100% --layout=reverse)
[ -n "${project:-}" ] || exit 0

session=$(session_name_for_path "$project")

if tmux has-session -t "=$session" 2>/dev/null; then
  tmux switch-client -t "=$session"
else
  tmux new-session -d -s "$session" -c "$project"
  tmux switch-client -t "=$session"
fi
