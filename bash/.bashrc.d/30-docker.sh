#!/usr/bin/env bash
########################
# Docker-specific setup
########################

# Only load if tool is present
command -v docker >/dev/null 2>&1 || return

alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcrun='docker-compose run -it --rm'