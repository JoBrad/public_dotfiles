#!/bin/zsh

# cd aliases
alias ..='cd ..'
alias ...='cd .. && cd ..'
alias ....='cd .. && cd .. && cd ..'
alias cd..='cd ..'

########################
# Prefer Gnu Utils
########################
# Check for GNU utils once
if [[ -x /opt/homebrew/bin/gls ]]; then
  _gnu_prefix=/opt/homebrew/bin/g
elif [[ -x /usr/local/bin/gls ]]; then
  _gnu_prefix=/usr/local/bin/g
else
  _gnu_prefix=""
fi

# Other GNU utils
if [[ -n "$_gnu_prefix" ]];
then
  [[ -x "${_gnu_prefix}ls" ]] && alias ls="${_gnu_prefix}ls --color=auto --group-directories-first --time-style='+%Y-%m-%d %H:%M:%S'"
  [[ -x "${_gnu_prefix}cp" ]] && alias cp="${_gnu_prefix}cp -bv" && alias cpa="${_gnu_prefix}cp -b --preserve=all"
  [[ -x "${_gnu_prefix}mv" ]] && alias mv="${_gnu_prefix}mv -bv"
  [[ -x "${_gnu_prefix}rm" ]] && alias rm="${_gnu_prefix}rm --preserve-root"
  [[ -x "${_gnu_prefix}sed" ]] && alias sed="${_gnu_prefix}sed"
  [[ -x "${_gnu_prefix}awk" ]] && alias awk="${_gnu_prefix}awk"
  [[ -x "${_gnu_prefix}tee" ]] && alias tee="${_gnu_prefix}tee"
  [[ -x "${_gnu_prefix}cut" ]] && alias cut="${_gnu_prefix}cut"
  [[ -x "${_gnu_prefix}tar" ]] && alias tar="${_gnu_prefix}tar"
  unset _gnu_prefix
else
  # Fallbacks for non-GNU systems
  alias ls='ls --color=auto -D "%Y-%m-%d %H:%M:%S"'
  alias cp='cp -iv' && alias cpa='cp -ip'
  alias mv='mv -iv'
fi

# ls aliases
alias l='ls -CF'
alias la="ls -A"
alias lsd='tree -daiL 1'
# Adds file classification indicators to entries.
# List of indicators:
#   / directory
#   * executable file
#   @ symbolic link
#   = socket
#   | named pipe
alias ll="ls -hAlF"
alias lw="ls -A"


alias tarc='tar -cavf'
alias tarx='tar -xavf'

# Make diff ignore spaces, and show results side by side
alias diff="diff --ignore-case --ignore-all-space --side-by-side"

# Re-run the last command as sudo
alias fuck='sudo $(history -p !!)'

# Reload .zshrc and clear the screen
alias cls='source ~/.zshrc && clear'

# Grep for process names, but don't return the grep process :)
function psgrep {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: psgrep <pattern>"
    echo "Returns all processes that contain PATTERN."
    return 0
  fi

  [[ -n "$1" ]] || {
    echo "Usage: psgrep <pattern>" >&2
    return 1
  }
  echo "Searching for processes matching: $1"
  ps aux | grep -v grep | grep "$1"
}
