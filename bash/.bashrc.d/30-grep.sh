#!/usr/bin/env bash

########################
# Grep color output
########################

# GREP_COLORS info
# bn    Byte offset prefixes
# cx    Non-matching lines when the -v command-line option is omitted, or matching lines when -v is specified
# fn    File name prefixes
# ln    Line number prefixes
# mc    Matching non-empty text in a context line, when -v is true.
# ms    Matching non-empty text in a selected line when -v is not true.
# mt    Matching non-empty text in any matching line
# ne    Prevents clearing to the end of line using Erase in Line (EL) to Right (\33[K) each time a colorized item ends
# rv    Reverses the meanings of sl and cx when the -v option is used
# se    Substring for inserted separators
# sl    Matching lines when the -v command-line option is omitted, or non-matching lines when -v is specified
# Default value is ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36
export GREP_COLORS="ms=01;36:mt=01;36:mc=01;36:sl=01;35:cx=01;35:fn=01;32:ln=32:bn=32:se=36"

alias egrep='egrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias fgrep='fgrep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias grep='grep --color=auto'
