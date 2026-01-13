#!/bin/bash
entries="Lock\nShutdown\nReboot\nLogout\nSuspend"
selected=$(echo -e $entries|wofi --width 250 --height 240 --dmenu --cache-file /dev/null | awk '{print tolower($1)}')

case $selected in
  lock)
    exec hyprlock;;
  logout)
    hyprctl dispatch exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac