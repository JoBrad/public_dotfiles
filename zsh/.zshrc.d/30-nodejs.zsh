#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# NPM config paths
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v node >/dev/null 2>&1 || return

export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc

if [[ ! -f "$XDG_CONFIG_HOME/npm/npmrc" ]]; then
  mkdir -p "$XDG_CONFIG_HOME/npm/"
  echo "prefix=${XDG_DATA_HOME}/npm" >"$XDG_CONFIG_HOME/npm/npmrc"
  echo "cache=${XDG_CACHE_HOME}/npm" >>"$XDG_CONFIG_HOME/npm/npmrc"
  echo "tmp=${XDG_RUNTIME_DIR}/npm" >>"$XDG_CONFIG_HOME/npm/npmrc"
  echo "init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js" >>"$XDG_CONFIG_HOME/npm/npmrc"
fi