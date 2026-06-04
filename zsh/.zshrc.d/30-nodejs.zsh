#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# NPM config paths
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v node > /dev/null 2>&1 || return
command -v npm > /dev/null 2>&1 || return


__npmjs_env_vars() {
  local xdg_data="${XDG_DATA_HOME:-$HOME/.local/share}"
  local xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
  local xdg_cache="${XDG_CACHE_HOME:-$HOME/.cache}"

  export NODE_REPL_HISTORY="${xdg_data}/node_repl_history"
  export NPM_CONFIG_USERCONFIG="${xdg_config}/npm/npmrc"
}

__npmjs_setup() {
  local xdg_data="${XDG_DATA_HOME:-$HOME/.local/share}"
  local xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
  local xdg_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
  local xdg_runtime="${XDG_RUNTIME_DIR:-$HOME/.tmp}"

  if [[ ! -f "${NPM_CONFIG_USERCONFIG}" ]]; then
    if [[ -d "${xdg_config}/npm" ]]; then
      echo "prefix=${xdg_data}/npm" > "${NPM_CONFIG_USERCONFIG}"
      echo "cache=${xdg_cache}/npm" >> "${NPM_CONFIG_USERCONFIG}"
      echo "tmp=${xdg_runtime}/npm" >> "${NPM_CONFIG_USERCONFIG}"
      echo "init-module=${xdg_config}/npm/config/npm-init.js" >> "${NPM_CONFIG_USERCONFIG}"
    fi
  fi
}

__npmjs_env_vars
__npmjs_setup
