# About

This folder contains user-specific customizations that
are loaded by bash.

# Loading files

To load these files on login, add this snippet to your .bash_aliases or .bashrc file:

```

########################
# Set Git repo root folder
########################
export GIT_REPO_HOME="${HOME}/git"

########################
# Load .bashrc.d folder
########################
export BASHRCD="${HOME}/.bashrc.d"

() {
  if [[ -s "${BASHRCD}" && -d "${BASHRCD}" ]]; then
    # shellcheck disable=SC2044
    for bashfile in $(find "${BASHRCD}" -name "*.sh" -type f)
    do
      # shellcheck disable=SC1090
      source "${bashfile}"
    done
  fi
}

```

# Load order

Files are sorted alphabetically when loaded. The standard convention here is to
prefix files numerically to ensure load order, if needed: 10-*, 20-*, etc.

