#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# devbox startup
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v devbox > /dev/null 2>&1 || return

function __nix_add_to_path() {
  # Add nix executable location to PATH, if missing
  # Returns error code if nix is not found
  local nix_in_path=$(command -v nix  > /dev/null 2>&1)
  [[ -n "$nix_in_path" ]] && return 0
  if [[ -f "/nix/var/nix/profiles/default/bin/nix" ]]; then
    path+=("/nix/var/nix/profiles/default/bin")
    return 0
  fi
  echo "Nix profile bin directory not found." >&2
  return 1
}

$(__nix_add_to_path  > /dev/null 2>&1) || return
