#!/usr/bin/env bash

#+++++++++++++++++++++++++++++++++++++
# Powershell updater
#+++++++++++++++++++++++++++++++++++++

# Only load if pwsh and brew are present
command -v pwsh >/dev/null 2>&1 || return
command -v brew >/dev/null 2>&1 || return

upgradepwsh() {
  brew upgrade powershell
  pwsh -Command 'Install-Module -Name PSWSMan -Force'
  sudo pwsh -Command 'Install-WSMan'
}
