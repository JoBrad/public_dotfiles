#!/usr/bin/env bash

# Don't save command history after logoff
export HISTFILESIZE=0

# Set window title on login
echo -en "\033]0;${USER}@${HOSTNAME%%.*}\a"