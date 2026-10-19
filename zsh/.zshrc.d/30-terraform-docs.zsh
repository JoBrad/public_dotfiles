#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# Terraform-docs config
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v terraform-docs 2>&1 > /dev/null || return

alias tfdocs='terraform-docs markdown table --output-file README.md --output-mode inject'
