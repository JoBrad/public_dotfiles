#!/bin/zsh

########################
# Terraform config
########################
# Enable terraform autocomplete
complete -o nospace -C /usr/local/bin/terraform terraform

# Set Terraform log file
export TF_LOG_PATH="${HOME}/.terraform/logs/terraform.log"
# Set Terraform log level
# Options: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG='WARN'

# Set Terraform cache dir
export TF_PLUGIN_CACHE_DIR="${HOME}/.local/share/terraform_plugin_cache"

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
# Terraform aliases
########################

alias tf='terraform'

alias tfi='tf init'

alias tfp='tf plan'
alias tfa='tf apply'
# alias tfd='tf destroy'

alias tfip='tfi && tfp'
alias tfia='tfi && tfa'
# alias tfid='tfi && tfd'

alias tfc='tf console'
alias tfg='tf graph'
alias tfget='tf get'
alias tfimp='tf import'
alias tfo='tf output'
alias tfprov='tf providers'
alias tfpp='tf push'
alias tfr='tf refresh'
alias tfs='tf show'
alias tfst='tf state'
alias tft='tf taint'
alias tfunt='tf untaint'
alias tfv='tf validate'
alias tfver='tf version'
alias tfw='tf workspace'
