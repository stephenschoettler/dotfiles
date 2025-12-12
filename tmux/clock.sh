#!/usr/bin/env bash

# --- Configuration ---
PADDING_X=6                   # Extra breathing room inside the box
COLOR_THEME='\033[38;2;80;250;123m' # Green #50FA7B
BG_COLOR='\033[48;2;40;42;54m' # Dracula bg #282A36

# --- Setup ---
trap 'tput cnorm; printf "\\033[49m"; clear; exit 0' INT TERM EXIT
HIDE_CURSOR='\033[?25l'
COLOR_RESET=$(tput sgr0)
COLOR_BOLD=$(tput bold)

# --- The Font Definition ---
# Returns the specific row (1, 2, or 3) for a given digit
get_font_fragment() {
  local char="$1"
  local row="$2"

  case "$char" in
  0)
    [ "$row" -eq 1 ] && echo -n " ▄██▄ "
    [ "$row" -eq 2 ] && echo -n "██  ██"
    [ "$row" -eq 3 ] && echo -n " ▀██▀ "
    ;;
  1)
    [ "$row" -eq 1 ] && echo -n "▄██"
    [ "$row" -eq 2 ] && echo -n " ██"
    [ "$row" -eq 3 ] && echo -n " ██"
    ;;
  2)
    [ "$row" -eq 1 ] && echo -n "████▄"
    [ "$row" -eq 2 ] && echo -n " ▄██▀"
    [ "$row" -eq 3 ] && echo -n "███▄▄"
    ;;
  3)
    [ "$row" -eq 1 ] && echo -n "████▄"
    [ "$row" -eq 2 ] && echo -n " ▄▄██"
    [ "$row" -eq 3 ] && echo -n "▄▄▄█▀"
    ;;
  4)
    [ "$row" -eq 1 ] && echo -n "██  ██"
    [ "$row" -eq 2 ] && echo -n "▀█████"
    [ "$row" -eq 3 ] && echo -n "    ██"
    ;;
  5)
    [ "$row" -eq 1 ] && echo -n "███▀▀▀"
    [ "$row" -eq 2 ] && echo -n "▀▀███▄"
    [ "$row" -eq 3 ] && echo -n "▄▄▄██▀"
    ;;
  6)
    [ "$row" -eq 1 ] && echo -n "▄██▀▀▀"
    [ "$row" -eq 2 ] && echo -n "██▄▄▄ "
    [ "$row" -eq 3 ] && echo -n "▀█▄▄█▀"
    ;;
  7)
    [ "$row" -eq 1 ] && echo -n "██████"
    [ "$row" -eq 2 ] && echo -n "   ▄██▀"
    [ "$row" -eq 3 ] && echo -n " ██▀  "
    ;;
  8)
    [ "$row" -eq 1 ] && echo -n "▄████▄"
    [ "$row" -eq 2 ] && echo -n "██▄▄██"
    [ "$row" -eq 3 ] && echo -n "▀█▄▄█▀"
    ;;
  9)
    [ "$row" -eq 1 ] && echo -n "▄█▀▀█▄"
    [ "$row" -eq 2 ] && echo -n " ▀▀▀██"
    [ "$row" -eq 3 ] && echo -n " ▄▄██▀"
    ;;
  :)
    # Custom Colon using half-blocks
    [ "$row" -eq 1 ] && echo -n " ▄ "
    [ "$row" -eq 2 ] && echo -n "   "
    [ "$row" -eq 3 ] && echo -n " ▀ "
    ;;
  *) # Space or unknown
    echo -n "  "
    ;;
  esac
}

draw_box() {
  local time_str="$1"
  local date_str="$2"
  local ampm_str="$3"

  # --- Step 1: Build the ASCII Art Strings ---
  local line1=""
  local line2=""
  local line3=""

  # Loop through every character in the time string (e.g., "1", "2", ":", "0", "0")
  for ((i = 0; i < ${#time_str}; i++)); do
    char="${time_str:$i:1}"
    line1="${line1}$(get_font_fragment "$char" 1) "
    line2="${line2}$(get_font_fragment "$char" 2) "
    line3="${line3}$(get_font_fragment "$char" 3) "
  done

  # --- Step 2: Calculate Dimensions ---
  # We strip ANSI codes to get true length, though our font has no colors embedded yet
  local ascii_width=${#line1}
  local date_len=$((${#date_str} + 1)) # +1 for Emoji adjustment

  # Who is wider? The giant ASCII text or the date string?
  local content_width=$((ascii_width > date_len ? ascii_width : date_len))
  local box_width=$((content_width + PADDING_X + 2))

  local term_cols=$(tput cols)
  local term_lines=$(tput lines)

  # Center Positions
  # Box is now taller (3 lines of text + 1 line date + 2 borders = 6 lines tall)
  local start_row=$(((term_lines - 7) / 2))
  local start_col=$(((term_cols - box_width) / 2))
  local end_col=$((start_col + box_width - 1))

  # --- Step 3: Draw The Box ---

  # Top Border


  # ASCII Line 1
  tput cup $((start_row + 1)) "$start_col"

  local pad_l=$(((box_width - ascii_width) / 2))
  tput cup $((start_row + 1)) $((start_col + pad_l))
  printf "${COLOR_THEME}${COLOR_BOLD}%s${COLOR_RESET}" "$line1"
  tput cup $((start_row + 1)) "$end_col"


  # ASCII Line 2
  tput cup $((start_row + 2)) "$start_col"
  
  tput cup $((start_row + 2)) $((start_col + pad_l))
  printf "${COLOR_THEME}${COLOR_BOLD}%s${COLOR_RESET}" "$line2"
  tput cup $((start_row + 2)) "$end_col"
  

  # ASCII Line 3
  tput cup $((start_row + 3)) "$start_col"
  
  tput cup $((start_row + 3)) $((start_col + pad_l))
  printf "${COLOR_THEME}${COLOR_BOLD}%s${COLOR_RESET}" "$line3"
  local clock_right=$((start_col + pad_l + ascii_width + 2))
  tput cup $((start_row + 3)) "$clock_right"
  printf "${COLOR_THEME}${COLOR_BOLD}%s${COLOR_RESET}" "$ampm_str"
  tput cup $((start_row + 3)) "$end_col"
  

  # Date Line (Standard Text)
  local row_date=$((start_row + 5))
  local date_pad=$(((box_width - date_len) / 2))
  tput cup "$row_date" "$start_col"
  
  tput cup "$row_date" $((start_col + date_pad))
  printf "${COLOR_THEME}%s${COLOR_RESET}" "$date_str"
  tput cup "$row_date" "$end_col"
  






}

# --- Main Loop ---
tput civis
printf "${BG_COLOR}\033[2J"

last_time=""
last_date=""
last_cols=0
last_lines=0

while true; do
  # Get time in HH:MM format (removed seconds/AMPM to keep it clean, add back if desired)
  # The font only supports numbers and colons!
  current_time=$(date '+%I:%M')
  current_date=$(date '+%A %B %d, %Y')
  current_ampm=$(date '+%p')
  
  # Check terminal size
  current_cols=$(tput cols)
  current_lines=$(tput lines)

  # Only redraw if something changed
  if [[ "$current_time" != "$last_time" ]] || \
     [[ "$current_date" != "$last_date" ]] || \
     [[ "$current_cols" != "$last_cols" ]] || \
     [[ "$current_lines" != "$last_lines" ]]; then

    printf "${BG_COLOR}\033[2J"
    draw_box "$current_time" "$current_date" "$current_ampm"
    
    # Park Cursor
    tput cup "$current_lines" "$current_cols"
    printf "${HIDE_CURSOR}"

    last_time="$current_time"
    last_date="$current_date"
    last_cols="$current_cols"
    last_lines="$current_lines"
  fi

  read -rsn1 -t 0.25 input
  if [ -n "$input" ]; then
    break
  fi
done
