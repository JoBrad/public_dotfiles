# About

This folder contains user-specific customizations that
are loaded by zsh. On my Mac, I've installed Gnu tools,
since they provide more functionality. Use if you like.

# Loading files

To load these files on login, add this snippet to your .zshrc file:

```

########################
# Set Git repo root folder
########################
export GIT_REPO_HOME="${HOME}/git"

########################
# Load .zshrc.d folder
########################
export ZSHRCD="${HOME}/.zshrc.d"

() {
  # make sure we found the zshrc.d
  if [[ -s "${ZSHRCD}" && -d "${ZSHRCD}" ]]; then
    # source all files in zshrc.d
    local conf_files=("$ZSHRCD"/*.{sh,zsh}(N))
    local f
    for f in ${(o)conf_files}; do
      # ignore files that begin with a tilde
      case ${f:t} in '~'*) continue;; esac
      source "${f}"
    done
  fi
}

```

# Load order

Files are sorted alphabetically when loaded. The standard convention here is to
prefix files numerically to ensure load order, if needed: 10-*, 20-*, etc.

