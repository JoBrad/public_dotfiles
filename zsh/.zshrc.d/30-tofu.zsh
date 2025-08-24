#!/bin/zsh
########################
# OpenTofu config
########################
# Only load if tool is present
command -v tofu >/dev/null 2>&1 || return

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
# cf-terraforming aliases
########################
# alias cfgen='cf-terraforming generate --modern-import-block --provider-registry-hostname registry.opentofu.org  --terraform-binary-path=/opt/homebrew/bin/tofu'


########################
# Terraform aliases
########################
function use_tofu {
  echo "Setting 'tf' alias to tofu."
  alias tf='tofu'
}

function use_terraform {
  echo "😤 Setting 'tf' alias to tofu."
  alias tf='terraform'
}

# alias tf='terraform'
alias tf='tofu'

alias tfi='tf init'
alias tfip='tfi && tfp'
alias tfia='tfi && tfa'
alias tfp='tf plan'
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
