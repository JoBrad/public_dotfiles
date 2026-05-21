#!/usr/bin/env bash

#+++++++++++++++++++++++++++++++++++++
# Custom AWS aliases with completer
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v aws >/dev/null 2>&1 || return

_getAWSConfigLocation() {
  # Prefer AWS_CONFIG_FILE
  [[ -n "${AWS_CONFIG_FILE}" ]] && echo "${AWS_CONFIG_FILE}" && return

  # Then XDG_CONFIG_HOME/aws
  local xdg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/aws"
  local legacy_dir="$HOME/.aws"
  local _config_dir="${xdg_dir}"

  # Then the legacy directory
  if [[ ! -d "${xdg_dir}" && -d "${legacy_dir}" ]]; then
    _config_dir="${legacy_dir}"
  fi

  echo "${_config_dir}/config"
}


# Completer for functions that accept an AWS profile name
_aws_profile_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local config_file="${AWS_CONFIG_FILE}"

  # Check if cache needs refreshing
  if [[ -f "$config_file" ]]; then
    local current_mtime=$(stat -c %Y "$config_file" 2>/dev/null || stat -f %m "$config_file" 2>/dev/null)
    if [[ "$current_mtime" != "$_AWS_CONFIG_MTIME" ]]; then
      _AWS_PROFILES_CACHE=$(awslistprofile 2>/dev/null)
      _AWS_CONFIG_MTIME="$current_mtime"
    fi
  fi

  COMPREPLY=($(compgen -W "$_AWS_PROFILES_CACHE" -- "$cur"))
}

_validate_aws_config() {
  local config_file="${AWS_CONFIG_FILE}"
  if [[ -z "$config_file" ]]; then
    echo "Error: AWS_CONFIG_FILE is not set" >&2
    return 1
  elif [[ ! -f "$config_file" ]]; then
    echo "Error: AWS config file '$config_file' not found" >&2
    return 1
  fi
}

awsenvclear() {
  # Handle help flags
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: awsenvclear"
    echo "Unsets AWS CLI environment variables: AWS_PROFILE, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN."
    return 0
  fi
  unset AWS_PROFILE AWS_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

awslistprofile() {
  # Handle help flags
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: awslistprofile [<profile-name>]"
    echo "Returns a list of configured AWS profiles, optionally filtered by profile_name."
    return 0
  fi
  _validate_aws_config || return 1
  local config_file="${AWS_CONFIG_FILE}"

  local profiles
  profiles=$(sed -n 's/^\[profile \(.*\)\]$/\1/p; s/^\[\([^]]*\)\]$/\1/p' "$config_file")

  if [[ -n "$1" ]]; then
    echo "$profiles" | grep -i "$1"
  else
    echo "$profiles"
  fi
}

awsgetregion() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: awsgetregion <profile-name>"
    echo "Returns the AWS region configured for the specified profile"
    return 0
  fi

  local profile="$1"
  [[ -n "$profile" ]] || {
    echo "Usage: awsgetregion <profile-name>" >&2
    return 1
  }

  if ! awslistprofile | grep -q "^${profile}$"; then
    echo "Error: Profile '$profile' not found" >&2
    return 1
  fi

  _validate_aws_config || return 1
  local config_file="${AWS_CONFIG_FILE}"

  local region
  region=$(sed -n "/^\[profile $profile\]$/,/^\[/{/^region[[:space:]]*=/{s/^region[[:space:]]*=[[:space:]]*//p;q;}};/^\[$profile\]$/,/^\[/{/^region[[:space:]]*=/{s/^region[[:space:]]*=[[:space:]]*//p;q;}}" "$config_file")

  if [[ -z "$region" ]]; then
    echo "Error: Profile '$profile' has no region configured" >&2
    return 1
  fi

  echo "$region"
}

awssetprofile() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: awssetprofile <profile-name>"
    echo "Sets AWS_PROFILE and AWS_REGION environment variables"
    return 0
  fi

  local profile="$1"
  local region
  [[ -n "$profile" ]] || {
    echo "Usage: awssetprofile <profile-name>" >&2
    return 1
  }

  if ! awslistprofile | grep -q "^${profile}$"; then
    echo "Error: Profile '$profile' not found" >&2
    return 1
  fi

  export AWS_PROFILE="$profile"
  unset AWS_REGION

  if region=$(awsgetregion "$profile" 2>/dev/null); then
    export AWS_REGION="$region"
  fi

  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "Not logged in to AWS, running 'aws sso login'..."
    aws sso login --profile "$profile"
  fi

  echo "AWS_PROFILE: $AWS_PROFILE"
  echo "AWS_REGION: $region"
}


# Cache variables
_AWS_PROFILES_CACHE=""
_AWS_CONFIG_MTIME=""

export AWS_CONFIG_FILE=$(_getAWSConfigLocation)
unset -f _getAWSConfigLocation

alias awsls="awslistprofile"
alias awssp="awssetprofile"
alias awswho="aws sts get-caller-identity"

complete -F _aws_profile_complete awsgetregion awssetprofile awssp

#+++++++++++++++++++++++++++++++++++++
# End Custom AWS Plugin
#+++++++++++++++++++++++++++++++++++++