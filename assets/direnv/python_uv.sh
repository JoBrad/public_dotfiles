#!/usr/bin/env bash

####################################
# Activate a Python virtual environment
# that was created by uv.
#
# Usage (in a .envrc file):
# python_uv my_venv_path
# OR
# python_uv
####################################


function layout_python_uv() {
    local venv_dir="${1:-.venv}"
    local activate_bin

    if [[ -f "${venv_dir}" ]];
    then
        echo "Error: python_uv layout expects a venv path as the sole parameter."
        return 1
    fi

    if [[ -d "${venv_dir}" ]];
    then
        activate_bin="${venv_dir}/bin/activate"
        if [[ ! -f "${activate_bin}" ]];
        then
            echo "Error: python_uv layout could not find activate script at ${activate_bin}."
            return 1
        fi
    fi

    if [[ -z "${activate_bin}" ]];
    then
        echo 'Could not find virtual environment!'
    else
        echo "Activating virtual environment: ${venv_dir}"
        source "${activate_bin}"
    fi
}
