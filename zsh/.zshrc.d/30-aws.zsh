#!/usr/bin/env zsh

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


# Completer for functions that accept an AWS profile name.
_aws_profile_complete() {
  if [[ -z "$_aws_profiles_session_cache" ]]; then
    _aws_profiles_session_cache=(${(f)"$(awslistprofile 2>/dev/null)"})
  fi
  _describe 'AWS profiles' _aws_profiles_session_cache
}


_aws_profiles_cache_policy() {
  local config_file="${AWS_CONFIG_FILE}"
  [[ -f "$config_file" && "$config_file" -nt "$1" ]]
}


# Completer for functions that accept an AWS profile name
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

  # If filter provided, apply case-insensitive partial match
  if [[ -n "$1" ]]; then
    echo "$profiles" | grep -i "$1"
  else
    echo "$profiles"
  fi
}


awsgetregion() {
  # Handle help flags
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
  region=$(sed -n "/^\[profile $profile\]$/,/^\[/{ /^region[[:space:]]*=/{ s/^region[[:space:]]*=[[:space:]]*//p; q; } }; /^\[$profile\]$/,/^\[/{ /^region[[:space:]]*=/{ s/^region[[:space:]]*=[[:space:]]*//p; q; } }" "$config_file")

  if [[ -z "$region" ]]; then
    echo "Error: Profile '$profile' has no region configured" >&2
    return 1
  fi

  echo "$region"
}


# Set AWS env variables
awssetprofile() {
  # Handle help flags
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

  # Check if profile exists
  if ! awslistprofile | grep -q "^${profile}$"; then
    echo "Error: Profile '$profile' not found" >&2
    return 1
  fi

  # Set profile
  export AWS_PROFILE="$profile"
  # Unset region variables before setting to avoid incorrect config
  unset AWS_REGION

  # Get configured profile region
  if region=$(awsgetregion "$profile" 2>/dev/null); then
    export AWS_REGION="$region"
  fi

  # Check if logged in, login if needed
  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "Not logged in to AWS, running 'aws sso login'..."
    if ! aws sso login --profile "$profile"; then
      echo "Error: AWS SSO login failed" >&2
      return 1
    fi
  fi

  echo "AWS_PROFILE: $AWS_PROFILE"
  echo "AWS_REGION: $region"

}

export AWS_CONFIG_FILE=$(_getAWSConfigLocation)
unset -f _getAWSConfigLocation

alias awsls="awslistprofile"
alias awssp="awssetprofile"
alias awswho="aws sts get-caller-identity"

compdef _aws_profile_complete awsgetregion awssetprofile awssp
# Add this to the list of pending completions
# This doesn't actually get picked up. Need to find out why.
# _pending_completions+="compdef _aws_profile_complete awsgetregion awssetprofile awssp"$'\n'

#+++++++++++++++++++++++++++++++++++++
# End Custom AWS Plugin
#+++++++++++++++++++++++++++++++++++++
