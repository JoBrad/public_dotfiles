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

# Cache completions for 24 hours
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -C   # Right: skip checks when cache exists
else
  compinit      # Right: full init when no cache
fi

if [[ -d "$ZSHRCD" ]]; then
  for f in "$ZSHRCD"/*.{sh,zsh}(N); do
    [[ ${f:t} != ~* ]] && source "$f"
  done
fi

```

# Load order

Files are sorted alphabetically when loaded. The standard convention here is to
prefix files numerically to ensure load order, if needed: 10-*, 20-*, etc.

