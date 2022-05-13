#!/bin/zsh

########################
# AWS-specific setup
########################
if [[ -s $(command -v aws) ]];
then
  function sso() {
    local _cmd
    if [[ "" == "${1}" ]];
    then
      _cmd="aws sso login"
    else
      _cmd="aws sso login --profile ${1}"
    fi
    echo "Running ${_cmd}"
    eval ${_cmd}
  }
fi