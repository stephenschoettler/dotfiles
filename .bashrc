#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '


# Bash Aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

### SPACE INVADERS COLOR SCRIPT ###
colorscript exec 26
