#!/bin/zsh
# Enable this if you don't want to install the Python
# plugin for Zsh, but want to auto-activate Python venvs

#function cd() {
#	builtin cd "$@"
#
#	if [[ -z "$VIRTUAL_ENV" ]]; then
#		## If env folder is found, activate
#		if [[ -d ./venv ]]; then
#			source ./venv/bin/activate
#		fi
#	else
#		## If the current folder is outside of the VIRTUAL_ENV folder, deactivate the venv
#		parentdir="$(dirname "$VIRTUAL_ENV")"
#		if [[ "$PWD"/ != "$parentdir"/* ]]; then
#			deactivate
#		fi
#	fi
#}