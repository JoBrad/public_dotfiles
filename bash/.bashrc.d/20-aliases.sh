#!/usr/bin/env bash

alias tarc='tar -cavf'
alias tarx='tar -xavf'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias ~='cd ~'
alias ..='cd ..'
alias ...='cd .. && cd..'
alias cd..='cd ..'
alias ls='ls --color=auto --group-directories-first'
alias l='ls -C'
alias la='ls -A'
alias ll='ls -alFh'
alias xcp='cp --target-directory=./'

# Safe copy and move
alias cp='cp -b'
alias mv='mv -b'

# --preserve-root Prevents recursive operations on /
alias rm='rm --preserve-root'

# Make diff ignore spaces, and show results side by side
alias diff='diff --ignore-case --ignore-all-space --side-by-side'

# Re-run the last command as sudo
alias fuck='sudo $(history -p !!)'

# Reload .bashrc and clear the screen
alias cls='source ~/.bashrc && clear'
