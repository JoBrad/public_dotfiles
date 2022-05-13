#!/usr/bin/env bash

if [[ -s "$(command -v git)" && -s "${GIT_REPO_HOME}" && -d "${GIT_REPO_HOME}" ]];
then
  # shellcheck disable=SC2139
  alias cdgit="cd ${GIT_REPO_HOME}"
  alias gll="git status"
  alias ga='git add'
  alias gm="git merge"
  alias gc='git commit -m '
  alias gb='git branch'
  alias gcl='git config --list'
  alias gcll='git config --local --list'
fi
