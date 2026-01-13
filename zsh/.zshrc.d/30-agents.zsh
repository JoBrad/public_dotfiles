#!/usr/bin/env zsh

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

function addagentsfile {
    local target_dir=$(realpath "${1:-$(pwd)}")
    local source_file="${${(%):-%x}:A:h}/assets/agents/AGENTS.md"
    local target_file="${target_dir}/AGENTS.md"
    if [[ ! -f "${source_file}" ]];
    then
        echo "AGENTS template not found at ${source_file}"
        return 1
    fi
    if [[ -f "${target_file}" ]];
    then
        echo "AGENTS.md already exists in ${target_dir}"
        return 1
    else
        echo "Creating prompt: ${source_file}"
        cp "${source_file}" "${target_dir}/"
    fi
}