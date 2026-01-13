#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# Go config
#+++++++++++++++++++++++++++++++++++++

# Only load if the tool is present
_gocmd="$(command -v go)" || return

export GOPATH="${_gocmd}"