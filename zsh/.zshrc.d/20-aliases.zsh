#!/bin/zsh

alias cd..='cd ..'

# List only directories
alias lsd='ls -d */'

alias tarc='tar -cavf'
alias tarx='tar -xavf'

if [[ -s $(command -v gls) ]];
then
  # Why does Apple cripple Macs?!
  alias ls='gls --color=auto --group-directories-first'
  alias l='gls -C'
  alias la='gls -A'
  alias ll='gls -alFh'
  alias lw='gls -a --group-directories-first --color=auto'
else
  alias lw='ls -a --color=auto'
fi

if [[ -s $(command -v grm) ]];
then
  # --preserve-root Prevents recursive operations on /
  alias rm='grm --preserve-root'
fi

# Make diff ignore spaces, and show results side by side
alias diff='diff --ignore-case --ignore-all-space --side-by-side'

# Re-run the last command as sudo
alias fuck='sudo $(history -p !!)'

# Reload .zshrc and clear the screen
alias cls='source ~/.zshrc && clear'
