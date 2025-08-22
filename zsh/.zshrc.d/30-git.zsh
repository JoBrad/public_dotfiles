#!/bin/zsh
export GIT_REPO_HOME="${HOME}/git"

_gitcmd="$(command -v git)"

if [[ -s "${_gitcmd}" ]];
then
  if [[ -s "${GIT_REPO_HOME}" && -d "${GIT_REPO_HOME}" ]];
  then
    # shellcheck disable=SC2139
    alias cdgit="cd ${GIT_REPO_HOME}"
  fi

  function GitCheckoutAndPull() {
    local _branch="${1}"
    git checkout "${_branch}" && git pull
  }

  alias gchm="git checkout main || git checkout master"
  alias ga="git add"
  alias gb="git branch"
  alias gc="git commit -m "
  alias gch="git checkout"
  alias gchp="GitCheckoutAndPull"
  alias gcll="git config --local --list"
  alias gcl="git config --list"
  alias gf="git fetch"
  alias gfa="git fetch --all"
  alias gll="git status"
  alias gm="git merge"
  alias gp="git pull"

  # clone a repo, then open the directory in VSCode
  function gco() {
    local _repo=$1
    local _path=$(echo "${_repo}" | cut -d'/' -f2 | cut -d'.' -f1)
    git clone "${_repo}"
    echo "Opening the repo in VSCode"
    code "${_path}"
  }

  function gfd() {
    # For every subdirectory with a provisioned git repo, run git fetch --all && git pull
    for d in $(find ./ -depth 2 -type d -name .git);
    do
      local _dirname=$(basename $(dirname $d))
      echo -e "--------------------------------------\nFetching remote updates for ${_dirname}\n--------------------------------------"
      cd ${_dirname}
      git fetch --all && git pull
      cd ..
      echo -e "\n\n"
    done
  }
fi
unset _gitcmd
