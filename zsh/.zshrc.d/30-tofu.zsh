#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# OpenTofu config
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
_tfbin="$(command -v tofu 2>&1)"
_tfswitchbin="$(command -v tfswitch 2>&1)"

[[ "" == "${_tfbin}" && "" == "${_tfswitchbin}" ]] && return

if [[ "" == "${_tfbin}" && "" != "${_tfswitchbin}" ]]; then
  echo "Installing the latest version of tofu."
  tfswitch --latest
  _tfbin="$(command -v tofu > /dev/null 2>&1)"
fi

# Logging
export TF_LOG_PATH="${HOME}/.terraform/logs/terraform.log"
# Options: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG='ERROR'

# Set Terraform cache dir
export TF_PLUGIN_CACHE_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/tf_plugin_cache"

########################
# Terraform prompt configuration
########################
function tf_prompt_info() {
  # S show 'default' workspace in home dir
  [[ "$PWD" != ~ ]] || return
  # check if in terraform dir and file exists
  [[ -d .terraform && -r .terraform/environment ]] || return

  local workspace="$(< .terraform/environment)"
  echo "${ZSH_THEME_TF_PROMPT_PREFIX-[}${workspace:gs/%/%%}${ZSH_THEME_TF_PROMPT_SUFFIX-]}"
}
RPROMPT='$(tf_prompt_info)'

########################
# tfswitch config
########################
function set_tfswitch_config {
  local assets_dir="${${(%):-%x}:A:h}/assets"
  local source_file="${assets_dir}/tfswitch/.tfswitch_tofu.toml"
  if [[ "$1" == "terraform" ]]; then
    source_file="${${(%):-%x}:A:h}/assets/tfswitch/.tfswitch_terraform.toml"
  fi
  if [[ -f "${source_file}" ]]; then
    [[ -f ~/.tfswitch.toml ]] && rm ~/.tfswitch.toml
    ln -s "${source_file}" "${HOME}/.tfswitch.toml"
  else
    echo "Could not find tfswitch config template: ${source_file}"
  fi
}

########################
# Terraform aliases
########################

function use_tofu {
  echo "Setting 'tf' alias to tofu."
  alias tf='tofu'
  [[ "" != "${_tfswitchbin}" ]] && set_tfswitch_config tofu
}

function use_terraform {
  echo "😤 Setting 'tf' alias to tofu."
  alias tf='terraform'
  [[ "" != "${_tfswitchbin}" ]] && set_tfswitch_config terraform
}

alias tf='tofu'

alias tfi='tf init'
alias tfip='tfi && tfp'
alias tfia='tfi && tfa'
alias tfp='tf plan'
alias tfpnc='tf plan -no-color -concise'
alias tfa='tf apply'

alias tffmt='tf fmt'

alias tfc='tf console'
alias tfg='tf graph'
alias tfget='tf get'
alias tfimp='tf import'
alias tfo='tf output'
alias tfprov='tf providers'
alias tfpp='tf push'
alias tfr='tf refresh'
alias tfs='tf show'
alias tfv='tf validate'

alias tfst='tf state'
alias tfls='tf state list'
alias tfmv='tf state mv'
alias tft='tf taint'
alias tfunt='tf untaint'

alias tfw='tf workspace'
alias tfws='tf workspace select'
