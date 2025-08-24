# About

This folder contains user-specific customizations that
are loaded by bash.

# Loading files

To load these files on login, add this snippet to your .bash_aliases or .bashrc file:

```
########################
# Cache completions for 24 hours
########################
_comp_cache="${HOME}/.bash_completion_cache"
if [[ -f "$_comp_cache" && $(find "$_comp_cache" -mtime -1 2>/dev/null) ]]; then
  source "$_comp_cache"
else
  # Rebuild completion cache
  {
    complete -p 2>/dev/null
    # Add any custom completions here
  } > "$_comp_cache" 2>/dev/null
fi

########################
# Load .bashrc.d folder
########################
export BASHRCD="${HOME}/.bashrc.d"

if [[ -d "$BASHRCD" ]]; then
  for f in "$BASHRCD"/*.sh; do
    [[ -f "$f" && ! "${f##*/}" =~ ^~ ]] && source "$f"
  done
fi

```

# Load order

Files are sorted alphabetically when loaded. The standard convention here is to
prefix files numerically to ensure load order, if needed: 10-*, 20-*, etc.

