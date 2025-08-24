#!/usr/bin/env bash
########################
# AWS-specific setup
########################

# Only load if AWS CLI is present
command -v aws >/dev/null 2>&1 || return

export AWS_CONFIG_FILE="$HOME/.aws/config"

#+++++++++++++++++++++++++++++++++++++
# Custom AWS aliases with completer
#+++++++++++++++++++++++++++++++++++++

# Completer for functions that accept an AWS profile name
_aws_profile_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(awslistprofile)" -- "$cur"))
}

awsenvclear() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: awsenvclear"
    echo "Unsets AWS CLI environment variables: AWS_PROFILE, AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN."
    return 0
  fi
  unset AWS_PROFILE AWS_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

awslistprofile() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: awslistprofile [<profile-name>]"
    echo "Returns a list of configured AWS profiles, optionally filtered by profile_name."
    return 0
  fi
  local config_file="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
  [[ -f "$config_file" ]] || return 1

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

  local config_file="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
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

alias awsls="awslistprofile"
alias awssp="awssetprofile"
alias awswho="aws sts get-caller-identity"

complete -F _aws_profile_complete awsgetregion awssetprofile awssp

#+++++++++++++++++++++++++++++++++++++
# End Custom AWS Plugin
#+++++++++++++++++++++++++++++++++++++