#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# Update shell settings to enhance security and privacy
#+++++++++++++++++++++++++++++++++++++

# Don't save command history after logoff
export HISTFILESIZE=0

# Set window title on login
# echo -en "\033]0;${USER}@${HOSTNAME%%.*}\a"

# Reset window title on logout
# export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}"; echo -ne "\007"'
