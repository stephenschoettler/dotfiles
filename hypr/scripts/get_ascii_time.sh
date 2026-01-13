#!/usr/bin/env bash

# Function to get font fragment (adapted from clockexample.sh)
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
    [ "$row" -eq 2 ] && echo -n "  ▄██▀"
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

# Get current time
time_str=$(date '+%I:%M')
ampm_str=$(date '+%p')
date_str=$(date '+%A %B %d, %Y')

line1=""
line2=""
line3=""

# Build the 3 lines of ASCII art
for ((i = 0; i < ${#time_str}; i++)); do
  char="${time_str:$i:1}"
  line1="${line1}$(get_font_fragment "$char" 1) "
  line2="${line2}$(get_font_fragment "$char" 2) "
  line3="${line3}$(get_font_fragment "$char" 3) "
done

# Color definition (Dracula Green #50FA7B)
COLOR="#50FA7B"

# Add AM/PM to the end of the 3rd line with some spacing, and pad other lines to maintain alignment
line1="${line1}    "
line2="${line2}    "
line3="${line3}  ${ampm_str}"

# Output formatted for hyprlock using Pango markup
echo -e "<tt><span size='18pt' foreground='$COLOR'>$line1</span>\n<span size='18pt' foreground='$COLOR'>$line2</span>\n<span size='18pt' foreground='$COLOR'>$line3</span>\n\n<span size='12pt' foreground='$COLOR'>$date_str</span></tt>"
