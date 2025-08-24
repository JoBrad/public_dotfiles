#!/usr/bin/env bash

cmd="brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt grep"

echo "Running this command, to install Gnu utils" && echo $cmd
eval $cmd