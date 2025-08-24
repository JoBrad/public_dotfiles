#!/bin/zsh
# Only load if tool is present
command -v pwsh >/dev/null 2>&1 || return

function upgradepwsh() {
  brew upgrade powershell
  pwsh -Command 'Install-Module -Name PSWSMan -Force'
  sudo pwsh -Command 'Install-WSMan'
}
