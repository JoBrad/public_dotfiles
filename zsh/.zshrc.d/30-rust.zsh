#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# Go config
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v rust >/dev/null 2>&1 || return

export GOPATH="${_gocmd}"