#!/usr/bin/env bash
#
# -*- mode: shell-mode; -*-
#

# This is apparently handled by the bats loader
load helper_functions.sh

function make_gist_url() {
  local user=$1
  echo "${GISTS_API_BASE_URL}${user}${GISTS_API_USERS_SUFFIX}"
}

declare -r GISTS_API_BASE_URL="https://api.github.com/users/"
declare -r GISTS_API_USERS_SUFFIX="/gists"

# The users are extracted from the URL and used to direct
# how the stub will respond
declare -r CURL_ERROR_USER="curlerror"
declare -r EMPTY_RESPONSE_USER="empty"
declare -r EMPTY_HEADER_USER="emptyheader"
declare -r LESS_THAN_THIRTY_USER="lessthan30"
declare -r MORE_THAN_THIRTY_USER="morethan30"

# These constants are used in the tests to trigger certain behaviour
declare -r CURL_ERROR_URL=$(make_gist_url $CURL_ERROR_USER)
declare -r EMPTY_RESPONSE_URL=$(make_gist_url $EMPTY_RESPONSE_USER)
declare -r EMPTY_HEADER_URL=$(make_gist_url $EMPTY_HEADER_USER)
declare -r LESS_THAN_THIRTY_URL=$(make_gist_url $LESS_THAN_THIRTY_USER)
declare -r MORE_THAN_THIRTY_URL=$(make_gist_url $MORE_THAN_THIRTY_USER)


function finduser() {
  local url=$1
  echo $url | sed -e "s%${GISTS_API_BASE_URL}\(.*\)${GISTS_API_USERS_SUFFIX}%\\1%g"
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

# This will be set by the stub to the arguments that were passed
# in to the curl command
last_curl_arguments=""

# Copy of the returned text from the last 
last_curl_response=""

# Copy of the last return value
last_curl_exit_status=1

# This is a stub/mock for the curl command it should override this and
# can be programmed here to respond in a certain way.  
function curl() {
  last_curl_arguments="$@"

  last_curl_response=""

  last_curl_exit_status=0
  return $last_curl_exit_status
}
