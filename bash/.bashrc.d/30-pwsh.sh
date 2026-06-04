#!/usr/bin/env bash

#+++++++++++++++++++++++++++++++++++++
# Powershell updater
#+++++++++++++++++++++++++++++++++++++

# Only load if pwsh and brew are present
command -v pwsh > /dev/null 2>&1 || return
command -v brew > /dev/null 2>&1 || return

upgradepwsh() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo ""
    echo "Upgrade PowerShell to the latest version and install WSMan module"
    echo "Usage: $0"
    echo ""
    exit 0
  fi

  brew upgrade powershell
  pwsh -Command 'Install-Module -Name PSWSMan -Force'
  sudo pwsh -Command 'Install-WSMan'
}
