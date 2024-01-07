#
# Bash Aliases
#

# .bashrc
alias refresh='source .bashrc'

# Hyprland
alias hyprcon='nano ~/.config/hypr/hyprland.conf'
alias hyprstyle='nano ~/.config/hypr/style.css'

# Waybar
alias wbcon='sudo nano /etc/xdg/waybar/config'
alias wbstyle='sudo nano /etc/xdg/waybar/style.css'
alias wbrefresh='pkill waybar && waybar & disown'

# Brightness
alias brightness='brightnessctl set'

# Navigation
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ...'

# Files
alias ls='exa -ahl'

# Misc
alias c='clear && colorscript exec 26'

# gtop
alias top='gtop'
