#!/usr/bin/env bash

# Make a 2-line prompt with the format below
# The username color will change depending on whether
# the current user is root or not
# <username> [<current_directory>]
# ->

function get_fg_color() {
  if [[ "reset" == "$1" ]];
  then
    echo '\e[0m'
  else
    local _color=""
    local _mod=""
    local _color_mod=""
    while [ -n "$1" ]; do
      case "${1}" in
        "bold")
          _mod+="1;"
          ;;
        "underline")
          _mod+="2;"
          ;;
        "light"|"dark")
          _color_mod="$1"
          ;;
        "default")
          _color="39"
          ;;
        "black")
          _color="30"
          ;;
        "grey"|"gray")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="37"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="90"
          fi
          _color_mod=""
          ;;
        "red")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="91"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="31"
          fi
          _color_mod=""
          ;;
        "green")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="92"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="32"
          fi
          _color_mod=""
          ;;
        "yellow")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="93"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="33"
          fi
          _color_mod=""
          ;;
        "blue")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="94"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="34"
          fi
          _color_mod=""
          ;;
        "magenta")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="95"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="35"
          fi
          _color_mod=""
          ;;
        "cyan")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="96"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="36"
          fi
          _color_mod=""
          ;;
        "white")
          if [[ "light" == "${_color_mod}" ]];
          then
            _color="97"
          elif [[ "dark" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="37"
          fi
          _color_mod=""
          ;;
      esac
      shift
    done
    if [[ "" == "${_mod}" ]];
    then
      _mod="0;"
    fi
    echo '\e['${_mod}${_color}'m'
  fi
}

function get_bg_color() {
  if [[ "reset" == "$1" ]];
  then
    echo '\e[0m'
  else
    local _color=""
    local _mod=""
    local _color_mod=""
    while [ -n "$1" ]; do
      case "${1}" in
        "light"|"dark")
          _color_mod="$1"
          ;;
        "black")
          _color="40"
          ;;
        "grey"|"gray")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="47"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="100"
          fi
          _color_mod=""
          ;;
        "red")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="101"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="41"
          fi
          _color_mod=""
          ;;
        "green")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="102"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="42"
          fi
          _color_mod=""
          ;;
        "yellow")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="103"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="43"
          fi
          _color_mod=""
          ;;
        "blue")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="104"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="44"
          fi
          _color_mod=""
          ;;
        "magenta")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="105"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="45"
          fi
          _color_mod=""
          ;;
        "cyan")
          if [[ "light" == "${_color_mod}" || "" == "${_color_mod}" ]];
          then
            _color="106"
          elif [[ "dark" == "${_color_mod}" ]];
          then
            _color="46"
          fi
          _color_mod=""
          ;;
        "white")
          if [[ "light" == "${_color_mod}" ]];
          then
            _color="47"
          elif [[ "" == "${_color_mod}" || "dark" == "${_color_mod}" ]];
          then
            _color="107"
          fi
          _color_mod=""
          ;;
      esac
      shift
    done
    if [[ "" == "${_mod}" ]];
    then
      _mod="0;"
    fi
    echo '\e['${_mod}${_color}'m'
  fi
}

function get_info() {
  local _info=""
  while [ -n "$1" ]; do
    case "${1}" in
      "bell")
        _info+='\a'
        ;;
      "escape")
        _info+='\e'
        ;;
      "delete")
        _info+='\d'
        ;;
      "form_feed"|"form")
        _info+='\f'
        ;;
      "vertical_tab"|"vtab")
        _info+='\v'
        ;;
      "newline"|"lf")
        _info+='\n'
        ;;
      "carriage_return"|"cr")
        _info+='\r'
        ;;
      # HH = 24-hour format
      "time_HHMMss")
        _info+='\t'
        ;;
      "time_HHMM")
        _info+='\A'
        ;;
      # hh = 12-hour format
      "time_hhMMss")
        _info+='\T'
        ;;
      "time_hhMM")
        _info+='\@'
        ;;
      "date")
        _info+='\d'
        ;;
      "short_host"|"host")
        _info+='\h'
        ;;
      "hostname"|"full_hostname"|"full_host"|"fqdn")
        _info+='\H'
        ;;
      "terminal")
        _info+='\l'
        ;;
      "shell")
        _info+='\s'
        ;;
      "bash_version")
        _info+='\v'
        ;;
      "bash_version_patch")
        _info+='\V'
        ;;
      "jobs")
        _info+='\j'
        ;;
      "history_num")
        _info+='\!'
        ;;
      "command_num")
        _info+='\#'
        ;;
      "user")
        _info+='\u'
        ;;
      "user_id"|"uid")
        _info+='\$'
        ;;
      "dir"|"directory"|"pwd")
        _info+='\w'
        ;;
      "dirname"|"base_dir")
        _info+='\W'
        ;;
    esac
    shift
  done
  echo "${_info}"
}

function getUserPromptColor() {
  if [[ "${LOGNAME}" == "root" ]];
  then
    # Local root user
    eval get_fg_color red
  fi
  # Local normal user
  if [[ "$TERM" == *"xterm-color"* || "$TERM" == *"-256color" ]];
  then
    eval get_fg_color light blue
  else
    eval get_fg_color blue
  fi
}


_usestarship=${USE_STARSHIP:no}

# if [ -n "$force_color_prompt" ]; then
#   if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
#   # We have color support; assume it's compliant with Ecma-48
#   # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
#   # a case would tend to support setf rather than setaf.)
#   color_prompt=yes
#     else
#   color_prompt=
#     fi
# fi
if [[ "yes" != "${_usestarship}" ]];
then
  # Custom Prompt
  PS1="$(get_fg_color reset)\\[$(getUserPromptColor)\\]$(get_info user) \\[$(get_fg_color reset)\\][$(get_info pwd)]\n\\[$(get_fg_color reset)\\]-> "
  PS2=" > "
fi

unset _usestarship