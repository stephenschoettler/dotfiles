#!/bin/bash

action=$(echo -e "Logout\nReboot\nShutdown" | wofi --show dmenu --prompt "Power:")

case $action in
    Logout)
        hyprctl dispatch exit
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    *)
        ;;
esac

