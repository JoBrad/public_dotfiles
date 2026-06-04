#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# Git aliases
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
_gitcmd="$(command -v git)" || return

export GIT_REPO_HOME="${GIT_REPO_HOME:-${HOME}/git}"

if [[ -s "${_gitcmd}" ]]; then
  if [[ -d "${GIT_REPO_HOME}" ]]; then
    # shellcheck disable=SC2139
    alias cdgit="cd ${GIT_REPO_HOME}"
    [[ -d "${GIT_REPO_HOME}/infrastructure/" ]] && alias cdinf="cd ${GIT_REPO_HOME}/infrastructure/"
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
    local helpmsg="
    Clone a repo then open the directory in VSCode

    Usage: gco REPO_URL
    "

    if [[ -z "${_repo}" ]]; then
      echo "Missing repo URL argument."
      echo "${helpmsg}"
      exit 1
    fi

    if [[ "${_repo}" == "-h" || "${_repo}" == "--help" ]]; then
      echo "${helpmsg}"
      exit 0
    fi

    # Make sure the repo URL ends with .git
    if [[ "${_repo}" != *.git ]]; then
      echo "Error: Repo URL must end with .git"
      exit 1
    fi

    local _path="${_repo##*/}"
    _path="${_path%.git}"
    git clone "${_repo}"
    echo "Opening the repo in VSCode"
    code "${_path}"
  }

  function gfd() {
    # For every subdirectory with a provisioned git repo, run git fetch --all && git pull
    while IFS= read -r -d '' d; do
      local _dirname=$(basename "$(dirname "$d")")
      echo -e "--------------------------------------\nFetching remote updates for ${_dirname}\n--------------------------------------"
      (cd "${_dirname}" && git fetch --all && git pull)
      echo -e "\n\n"
    done < <(find ./ -depth 2 -type d -name .git -print0)
  }
fi
unset _gitcmd
