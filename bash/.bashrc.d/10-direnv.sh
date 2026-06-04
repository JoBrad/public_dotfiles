#!/usr/bin/env bash

#+++++++++++++++++++++++++++++++++++++
# direnv startup
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v direnv >/dev/null 2>&1 || return

export DIRENV_CONFIG="${XDG_CONFIG_HOME}/direnv"
export DIRENV_LIB="${DIRENV_CONFIG}/lib"

__direnv_load_scripts() {
    local my_location="${BASH_SOURCE[0]}"
    my_location="${my_location%/}"
    local direnv_asset_dir
    direnv_asset_dir="${my_location%/*}/assets/direnv"
    if [[ -d "${direnv_asset_dir}" ]];
    then
        while IFS= read -r -d '' scriptfile; do
            # Don't overwrite existing scripts in the lib directory
            if [[ ! -f "${DIRENV_LIB}/${scriptfile##*/}" ]];
            then
                cp "$scriptfile" "${DIRENV_LIB}/"
            fi
        done < <(find "${direnv_asset_dir}" -type f -name "*.sh" -print0)
    fi
}

[[ ! -d "${DIRENV_LIB}" ]] && mkdir -p "${DIRENV_LIB}"
__direnv_load_scripts
unset -f __direnv_load_scripts

eval "$(direnv hook bash)"
