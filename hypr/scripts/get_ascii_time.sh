#!/usr/bin/env bash
set -euo pipefail

readonly COLOR="#50FA7B"
readonly TIME_SIZE="18pt"

get_font_fragment() {
  local char="$1"
  local row="$2"

  case "$char" in
  0)
    [ "$row" -eq 1 ] && printf '%s' " ▄██▄ "
    [ "$row" -eq 2 ] && printf '%s' "██  ██"
    [ "$row" -eq 3 ] && printf '%s' " ▀██▀ "
    ;;
  1)
    [ "$row" -eq 1 ] && printf '%s' "▄██"
    [ "$row" -eq 2 ] && printf '%s' " ██"
    [ "$row" -eq 3 ] && printf '%s' " ██"
    ;;
  2)
    [ "$row" -eq 1 ] && printf '%s' "████▄"
    [ "$row" -eq 2 ] && printf '%s' " ▄██▀"
    [ "$row" -eq 3 ] && printf '%s' "███▄▄"
    ;;
  3)
    [ "$row" -eq 1 ] && printf '%s' "████▄"
    [ "$row" -eq 2 ] && printf '%s' " ▄▄██"
    [ "$row" -eq 3 ] && printf '%s' "▄▄▄█▀"
    ;;
  4)
    [ "$row" -eq 1 ] && printf '%s' "██  ██"
    [ "$row" -eq 2 ] && printf '%s' "▀█████"
    [ "$row" -eq 3 ] && printf '%s' "    ██"
    ;;
  5)
    [ "$row" -eq 1 ] && printf '%s' "███▀▀▀"
    [ "$row" -eq 2 ] && printf '%s' "▀▀███▄"
    [ "$row" -eq 3 ] && printf '%s' "▄▄▄██▀"
    ;;
  6)
    [ "$row" -eq 1 ] && printf '%s' "▄██▀▀▀"
    [ "$row" -eq 2 ] && printf '%s' "██▄▄▄ "
    [ "$row" -eq 3 ] && printf '%s' "▀█▄▄█▀"
    ;;
  7)
    [ "$row" -eq 1 ] && printf '%s' "██████"
    [ "$row" -eq 2 ] && printf '%s' "  ▄██▀"
    [ "$row" -eq 3 ] && printf '%s' " ██▀  "
    ;;
  8)
    [ "$row" -eq 1 ] && printf '%s' "▄████▄"
    [ "$row" -eq 2 ] && printf '%s' "██▄▄██"
    [ "$row" -eq 3 ] && printf '%s' "▀█▄▄█▀"
    ;;
  9)
    [ "$row" -eq 1 ] && printf '%s' "▄█▀▀█▄"
    [ "$row" -eq 2 ] && printf '%s' " ▀▀▀██"
    [ "$row" -eq 3 ] && printf '%s' " ▄▄██▀"
    ;;
  :)
    [ "$row" -eq 1 ] && printf '%s' " ▄ "
    [ "$row" -eq 2 ] && printf '%s' "   "
    [ "$row" -eq 3 ] && printf '%s' " ▀ "
    ;;
  *)
    printf '%s' "  "
    ;;
  esac

  return 0
}

time_str=$(date '+%I:%M')
ampm_str=$(date '+%p')

line1=""
line2=""
line3=""

for ((i = 0; i < ${#time_str}; i++)); do
  char="${time_str:$i:1}"
  line1="${line1}$(get_font_fragment "$char" 1) "
  line2="${line2}$(get_font_fragment "$char" 2) "
  line3="${line3}$(get_font_fragment "$char" 3) "
done

line1="${line1}    "
line2="${line2}    "
line3="${line3}  ${ampm_str}"

printf "<tt><span size='%s' foreground='%s'>%s</span>\n<span size='%s' foreground='%s'>%s</span>\n<span size='%s' foreground='%s'>%s</span></tt>\n" \
  "$TIME_SIZE" "$COLOR" "$line1" \
  "$TIME_SIZE" "$COLOR" "$line2" \
  "$TIME_SIZE" "$COLOR" "$line3"
