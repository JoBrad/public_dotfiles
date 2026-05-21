#!/usr/bin/env zsh


#+++++++++++++++++++++++++++++++++++++
# direnv startup
#+++++++++++++++++++++++++++++++++++++

# Only load if tool is present
command -v direnv >/dev/null 2>&1 || return

if [[ ! -d "${XDG_CONFIG_HOME}/direnv/lib/" ]];
then
    mkdir -p "${XDG_CONFIG_HOME}/direnv/lib/"
fi

for script in "${0:A:h}/assets/direnv/"*.sh(N);
do
    if [[ ! -f "${XDG_CONFIG_HOME}/direnv/lib/${script:t}" ]];
    then
        cp "$script" "${XDG_CONFIG_HOME}/direnv/lib/"
    fi
done

eval "$(direnv hook zsh)"
