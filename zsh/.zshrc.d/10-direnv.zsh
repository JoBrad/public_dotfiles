#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# direnv startup
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v direnv > /dev/null 2>&1 || return

export DIRENV_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/direnv"
export DIRENV_LIB="${DIRENV_CONFIG}/lib"

__direnv_load_scripts() {
  local my_location="${${(%):-%x}:A:h}"
  local assets_dir="${CONFIG_ASSETS_DIR}"
  if [[ -z "${assets_dir}" ]]; then
    assets_dir="$(dirname "${my_location}")/assets"
  fi
  local direnv_asset_dir="${assets_dir}/direnv"

  if [[ -d "${direnv_asset_dir}" ]]; then
    for scriptfile in "${direnv_asset_dir}"/*.sh(N); do
      # Don't overwrite existing scripts in the lib directory
      if [[ ! -f "${DIRENV_LIB}/${scriptfile:t}" ]]; then
        cp "$scriptfile" "${DIRENV_LIB}/"
      fi
    done
  fi

}

[[ ! -d "${DIRENV_LIB}" ]] && mkdir -p "${DIRENV_LIB}"

__direnv_load_scripts
unset -f __direnv_load_scripts

eval "$(direnv hook zsh)"
