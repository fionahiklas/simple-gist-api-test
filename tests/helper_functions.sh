#!/usr/bin/env sh
#
# -*- mode: shell-mode; -*-
#

function echolog() { echo "LOG: $@" 1>&2; }
    

function finduser() {
  echo ""
}

function get_curl_url {
  for argument in $@
  do
    echolog "Argument: $argument"                
    # The double brackets are needed otherwise the shell gets confused  
    [[ $argument =~ ^http.*$ ]] && echo "$argument" && return
  done
  echo "Not Found"
}
