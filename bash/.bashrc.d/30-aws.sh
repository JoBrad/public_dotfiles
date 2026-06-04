#!/usr/bin/env bash

#+++++++++++++++++++++++++++++++++++++
# AWS Profile Manager script, and custom aliases
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v aws > /dev/null 2>&1 || return

__awp_getAWSConfigLocation() {
  #######################################
  # Locate the AWS configuration file, preferring AWS_CONFIG_FILE, then XDG_CONFIG_HOME/aws, then ~/.aws
  # This function will be unset after it is executed.
  #######################################

  # Respect existing AWS_CONFIG_FILE variable
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

_validate_aws_config() {
  #######################################
  # Validate that the discovered AWS configuration file exists and is readable
  #######################################

  local config_file="${AWS_CONFIG_FILE}"
  if [[ -z "$config_file" ]]; then
    echo "Error: AWS_CONFIG_FILE is not set" >&2
    return 1
  elif [[ ! -f "$config_file" ]]; then
    echo "Error: AWS config file '$config_file' not found" >&2
    return 1
  fi
}

_aws_profile_complete() {
  #######################################
  # Completer for functions that accept an AWS profile name.
  #######################################
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local config_file="${AWS_CONFIG_FILE}"
  local current_mtime

  # Check if cache needs refreshing
  if [[ -f "$config_file" ]]; then
    current_mtime=$(stat -c %Y "$config_file" 2> /dev/null || stat -f %m "$config_file" 2> /dev/null)
    if [[ "$current_mtime" != "$_AWS_CONFIG_MTIME" ]]; then
      # shellcheck disable=SC2119
      _AWS_PROFILES_CACHE=$(awslistprofile 2> /dev/null)
      _AWS_CONFIG_MTIME="$current_mtime"
    fi
  fi

  mapfile -t COMPREPLY < <(compgen -W "$_AWS_PROFILES_CACHE" -- "$cur")
}

# shellcheck disable=SC2120
__awp_awsenvclear() {
  #######################################
  # Clear AWS CLI environment variables
  #######################################
  local varnames=(
    AWS_PROFILE
    AWS_REGION
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    AWS_SESSION_TOKEN
  )
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: __awp_awsenvclear"
    echo "Unsets AWS CLI environment variables: ${varnames[*]}."
    return 0
  fi
  for var in "${varnames[@]}"; do
    unset "$var"
  done
}

# shellcheck disable=SC2120
awslistprofile() {
  local helpmsg="
  Usage: $0 [PROFILE_NAME]
  Return a list of configured AWS profiles, optionally filtered by PROFILE_NAME.

  Arguments:
    PROFILE_NAME   The name of the AWS profile

  "

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "$helpmsg"
    return 0
  fi

  __awp_validate_aws_config || return 1

  local profiles
  profiles=$(sed -n 's/^\[profile \(.*\)\]$/\1/p; s/^\[\([^]]*\)\]$/\1/p' "$AWS_CONFIG_FILE")

  # If filter provided, apply case-insensitive partial match
  if [[ -n "$1" ]]; then
    echo "$profiles" | grep -i "$1"
  else
    echo "$profiles"
  fi
}

awsgetregion() {
  local helpmsg="
  Usage: $0 PROFILE_NAME [DEFAULT_REGION]
  Return the AWS region configured for the specified profile

  Arguments:
    PROFILE_NAME    The name of the AWS profile
    DEFAULT_REGION  Optional default region to use if none is configured

  "

  local profile="$1"
  local default_region="${2:-}"

  if [[ "$profile" == "-h" || "$profile" == "--help" ]]; then
    echo "${helpmsg}"
    return 0
  fi

  [[ -n "$profile" ]] || {
    echo "Error: Profile name is required"
    echo "${helpmsg}"
    return 1
  }

  if ! awslistprofile | grep -q "^${profile}$"; then
    echo "Error: Profile '$profile' not found"
    return 1
  fi

  __awp_validate_aws_config || return 1
  local config_file="${AWS_CONFIG_FILE}"

  local region
  region=$(sed -n "/^\[profile $profile\]$/,/^\[/{ /^region[[:space:]]*=/{ s/^region[[:space:]]*=[[:space:]]*//p; q; } }; /^\[$profile\]$/,/^\[/{ /^region[[:space:]]*=/{ s/^region[[:space:]]*=[[:space:]]*//p; q; } }" "$config_file")

  if [[ -z "$region" ]]; then
    region="${default_region}"
  fi

  echo "$region"
}

awssetprofile() {
  local helpmsg="
  Usage: $0 PROFILE_NAME [REGION_NAME]
  Sets the AWS_PROFILE and AWS_REGION environment variables.

  Arguments:
    PROFILE_NAME   The name of the AWS profile
    REGION_NAME    The AWS region. If not provided, will use the profile's configured region, or us-east-1 if AWS_REGION is not set.

  "
  local profile="$1"
  local region="${2}"
  local _cur_aws_region="${AWS_REGION}"
  local fallback_region="us-east-1"
  local profile_region

  # Handle help flags
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "${helpmsg}"
    return 0
  fi

  [[ -n "$profile" ]] || {
    echo "Error: Profile name is required" >&2
    echo "${helpmsg}"
    return 1
  }

  # Check if profile exists
  if ! awslistprofile | grep -q "^${profile}$"; then
    echo "Error: Profile '$profile' not found" >&2
    return 1
  fi

  # Unset env variables before setting to avoid incorrect config
  # shellcheck disable=SC2119
  __awp_awsenvclear

  # Set profile
  export AWS_PROFILE="$profile"

  # Get configured profile region
  # Use provided region if given
  if [[ -z "$region" ]]; then
    profile_region=$(awsgetregion "$AWS_PROFILE" 2> /dev/null)
    if [[ -n "$profile_region" ]]; then
      region="$profile_region"
    elif [[ -n "$_cur_aws_region" ]]; then
      region="$_cur_aws_region"
    else
      region="$fallback_region"
    fi
  fi
  export AWS_REGION="$region"

  # Check if logged in, login if needed
  if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "Not logged in to AWS, running 'aws sso login'..."
    if ! aws sso login --profile "$AWS_PROFILE"; then
      echo "Error: AWS SSO login failed" >&2
      return 1
    fi
  fi

  echo "AWS_PROFILE: $AWS_PROFILE"
  echo "AWS_REGION: $AWS_REGION"

}

# Cache variables
_AWS_PROFILES_CACHE=""
_AWS_CONFIG_MTIME=""

# shellcheck disable=SC2155
export AWS_CONFIG_FILE=$(__awp_getAWSConfigLocation)
unset -f __awp_getAWSConfigLocation

alias awsgr="awsgetregion"
alias awsls="awslistprofile"
alias awssp="awssetprofile"
alias awswho="aws sts get-caller-identity"

complete -F __awp_aws_profile_complete awsgetregion awssetprofile awssp awsgr
