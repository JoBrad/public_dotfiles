#!/usr/bin/env zsh

#+++++++++++++++++++++++++++++++++++++
# Azure Profile Manager script, and custom aliases
#+++++++++++++++++++++++++++++++++++++


# Only load if az CLI is present
command -v az >/dev/null 2>&1 || return

__azure_is_sourced() {
  if [ -n "${BASH_VERSION-}" ]; then
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
  elif [ -n "${ZSH_VERSION-}" ]; then
    # shellcheck disable=SC2296
    (( zsh_eval_context[(I)file] ))
  else
    return 1
  fi
}

__azure_terminate() {
  local exit_code="${1:-0}"
  if __azure_is_sourced; then
    return "${exit_code}"
  else
    exit "${exit_code}"
  fi
}


# Symlinks azure-profile-manager in ~/.local/bin and add config, if they don't exist
_install_azp() {
    local bin_dir="${HOME}/.local/bin"
    local assets_dir="${${(%):-%x}:A:h}/assets"
    local source_file="${assets_dir}/azure/azure-profile-manager.sh"
    local target_file="${bin_dir}/azure-profile-manager.sh"
    if [[ ! -f "${source_file}" ]];
    then
        echo "Could not find Azure profile manager at ${source_file}!"
        return 1
    fi
    if [[ ! -f "${target_file}" ]];
    then
        [[ ! -d "${bin_dir}" ]] && mkdir -p "${bin_dir}"
        ln -s "${source_file}" "${target_file}"
        chmod +x "${source_file}"
    fi
    _mk_az_profiles_dir
}

# Returns the configuration path for Azure profile manager configuration
_get_az_profiles_dir() {
    echo "${XDG_CONFIG_HOME:-$HOME/.config}/.azure-profiles"
}

# Creates the configuration path and file for Azure profile manager, if it does not exist.
_mk_az_profiles_dir() {
    local profile_dir=$(_get_az_profiles_dir)
    if [[ ! -d "${profile_dir}" ]];
    then
        mkdir -p "${profile_dir}"
        echo '{}' > "${profile_dir}/profiles.json"
    fi
}

# Completion function for azure-profile-manager
_azure_profile_manager() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local commands=(
        'rm:Remove a profile'
        'switch:Switch to a profile'
        'show:Show current Azure CLI context'
        'help:Show help message'
    )

    local profile_dir=$(_get_az_profiles_dir)
    local profiles_config="${profile_dir}/profiles.json"

    # Get list of profile names from config
    _get_profiles() {
        if [[ -f "$profiles_config" ]] && command -v jq &>/dev/null; then
            jq -r 'keys[]' "$profiles_config" 2>/dev/null
        fi
    }

    _arguments -C \
        '1: :->command' \
        '2: :->arg1' \
        && return

    case $state in
        command)
            _describe -t commands 'azure-profile-manager commands' commands
            ;;
        arg1)
            case ${words[2]} in
                switch|use|remove|rm)
                    local profiles
                    profiles=(${(f)"$(_get_profiles)"})
                    _describe -t profiles 'profiles' profiles
                    ;;
                add)
                    _message 'profile name'
                    ;;
            esac
            ;;
    esac
}


main() {
  if ! _install_azp; then
    return 1
  fi

  alias azp="source ~/.local/bin/azure-profile-manager.sh"
  # Register completion for azp function/alias
  compdef _azure_profile_manager azp
  compdef _azure_profile_manager azure-profile-manager.sh
  return 0
}

main "$@"
__azure_terminate "$?"
