#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# XDG Base Directory Specification
#+++++++++++++++++++++++++++++++++++++

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Provides an environment variable for the location of the assets directory, which is used by other scripts to locate shared resources.
export CONFIG_ASSETS_DIR="${XDG_CONFIG_HOME}/zsh/assets"

[[ -d "${HOME}/.local/bin" ]] && path+=("${HOME}/.local/bin")
