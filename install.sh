#!/usr/bin/env bash

#+++++++++++++++++++++++++++++++++++++
# Installation script for dotfiles
#+++++++++++++++++++++++++++++++++++++

__setup_is_sourced() {
  if [ -n "${BASH_VERSION-}" ]; then
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0
  elif [ -n "${ZSH_VERSION-}" ]; then
    # shellcheck disable=SC2296
    (( zsh_eval_context[(I)file] )) && return 0
  fi
  return 1
}


__setup_terminate() {
  local exit_code="${1:-0}"
  if __setup_is_sourced; then
    return "${exit_code}"
  else
    exit "${exit_code}"
  fi
}


__setup_confirm() {
  local prompt="$1"

  read -r -p "${prompt} (y/n) " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi

}


__setup_showhelp() {
  echo ""
  echo "Usage: install-dotfiles SHELL_NAME"
  echo ""
  echo "  SHELL_NAME bash or zsh"
  echo ""
}


__setup_remove_managed_blocks() {
  local file_path="$1"
  local start_marker="$2"
  local end_marker="$3"
  local tmp_file

  [[ -f "$file_path" ]] || return 0

  tmp_file="$(mktemp "${file_path}.XXXXXX")" || return 1
  # Clean up this file on failure
  trap 'rm -f "$tmp_file"' RETURN

  awk -v start="$start_marker" -v end="$end_marker" '
    BEGIN { in_block = 0 }

    index($0, start) { in_block = 1; next }
    in_block && index($0, end) { in_block = 0; next }

    !in_block { print }
  ' "$file_path" > "$tmp_file" && mv "$tmp_file" "$file_path"
}


__setup_check_compinit() {
  local startup_file="$1"
  local example="
  ---------------------------------
  autoload -Uz compinit

  # Cache completions for 24 hours
  local zcompdump=\"\${ZDOTDIR:-\$HOME}/.zcompdump\"

  if [[ \$zcompdump(#qNmh+24) ]]; then
    compinit -u -d \"\$zcompdump\"
  else
    compinit -u -C -d \"\$zcompdump\"
  fi
  ---------------------------------
  "
  local found=0
  if [[ -f "$startup_file" ]]; then
    if grep -Fq "compinit " "$startup_file"; then
      found=1
    fi
  fi
  if [[ $found -eq 0 ]]; then
    echo "compinit not found in ${startup_file}. You may want to add the following content to enable completion caching:"
    echo ""
    echo "${example}"
    echo ""
  fi
}


__setup_main() {
  set -euo pipefail
  local shell_name="$1"

  if [[ "$shell_name" == "-h" || "$shell_name" == "--help" ]]; then
    __setup_showhelp
    return 0
  fi

  if [[ -z "$shell_name" ]]; then
    echo "Error: SHELL_NAME argument is required." >&2
    __setup_showhelp
    return 1
  fi

  local conf_home
  local file_suffix
  local env_var_name
  local startup_file
  local sourcedir_basename
  local sourcedir
  local target_parentdir
  local targetdir
  local startup_content
  local startup_prefix
  local startup_suffix

  if [[ "${shell_name}" != "bash" && "${shell_name}" != "zsh" ]];
  then
    echo "Error: Unsupported shell '${shell_name}'. Supported shells are 'bash' and 'zsh'." >&2
    return 1
  fi

  conf_home="${XDG_CONFIG_HOME:-$HOME/.config}"

  if [[ "${shell_name}" == "zsh" ]]; then
    file_suffix=".zsh"
    startup_file="${ZDOTDIR:-$HOME}/.zshrc"
  else
    file_suffix=".sh"
    startup_file="${HOME}/.bashrc"
  fi

  env_var_name="$(printf '%s' "$shell_name" | tr '[:lower:]' '[:upper:]')RCD"
  sourcedir_basename=".${shell_name}rc.d"
  sourcedir="./${shell_name}/${sourcedir_basename}"
  target_parentdir="${conf_home}/${shell_name}"
  targetdir="${target_parentdir}/${sourcedir_basename}"

  echo ""
  echo "****************************************"
  echo "Setting up dotfiles for ${shell_name}..."
  echo ""
  echo "Target location: ${target_parentdir}"
  echo "Startup file: ${startup_file}"
  echo "New environment variable: ${env_var_name}"
  echo "****************************************"
  echo ""

  if [[ -d "${targetdir}" ]]; then
    __setup_confirm "Target directory ${targetdir} already exists. Do you want to overwrite it?" || return 0
  else
    if __setup_confirm "Create ${targetdir}?"; then
      mkdir -p "${targetdir}"
    else
      echo "Error: Cannot continue without a config directory. Exiting." >&2
      return 1
    fi
  fi

  __setup_check_compinit "${startup_file}"

  echo "Copying files from ${sourcedir} to ${target_parentdir}"
  __setup_confirm "Continue?" || return 0
  cp -r "${sourcedir}" "${target_parentdir}"

  echo "Copying files from ./assets to ${targetdir}/"
  __setup_confirm "Continue?" || return 0
  cp -r assets "${targetdir}/"

  startup_prefix="#####--##### ${env_var_name} load start #####--#####"
  startup_suffix="#####--##### ${env_var_name} load end #####--#####"

  startup_content="${startup_prefix}

  ########################
  # Load ${sourcedir_basename} folder
  ########################
  ${env_var_name}="${targetdir}"

  if [[ -d \"\${${env_var_name}}\" ]]; then
    while IFS= read -r -d '' scriptfile; do
      [[ ! "\${scriptfile##*/}" =~ ^~ ]] && source \"\${scriptfile}\"
    done < <(find \"\${${env_var_name}}\" -maxdepth 1 -type f -name \"*${file_suffix}\" -print0 | sort -z)
  fi

  ${startup_suffix}
  "

  local found=0
  if [[ -f "$startup_file" ]] && grep -Fq -- "$startup_prefix" "$startup_file"; then
    found=1
  fi
  if [[ $found -eq 1 ]]; then
    if __setup_confirm "Existing managed block found in ${startup_file}. Remove it first?"; then
      __setup_remove_managed_blocks "$startup_file" "$startup_prefix" "$startup_suffix"
    else
      echo "You will need to manually remove the content from your startup file."
    fi
  fi

  echo "Adding the following content to ${startup_file}"
  echo ""
  echo "${startup_content}"
  echo ""
  if __setup_confirm "Continue?"; then
    echo "$startup_content" >> "${startup_file}"
  else
    echo "Aborting without modifying ${startup_file}."
    return 0
  fi

}


__setup_main "$@"
__setup_terminate "$?"
