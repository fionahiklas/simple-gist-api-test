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


export GISTS_API_BASE_URL="https://api.github.com/users/"
export GISTS_API_USERS_SUFFIX="/gists"

# The users are extracted from the URL and used to direct
# how the stub will respond
export CURL_ERROR_USER="curlerror"
export EMPTY_RESPONSE_USER="empty"
export EMPTY_HEADER_USER="emptyheader"
export LESS_THAN_THIRTY_USER="lessthan30"
export MORE_THAN_THIRTY_USER="morethan30"

# These constants are used in the tests to trigger certain behaviour
export CURL_ERROR_URL=$(make_gist_url $CURL_ERROR_USER)
export EMPTY_RESPONSE_URL=$(make_gist_url $EMPTY_RESPONSE_USER)
export EMPTY_HEADER_URL=$(make_gist_url $EMPTY_HEADER_USER)
export LESS_THAN_THIRTY_URL=$(make_gist_url $LESS_THAN_THIRTY_USER)
export MORE_THAN_THIRTY_URL=$(make_gist_url $MORE_THAN_THIRTY_USER)


get_user() {
  local url=$1
  echo $url | sed -e "s%${GISTS_API_BASE_URL}\(.*\)${GISTS_API_USERS_SUFFIX}%\\1%g"
}

get_curl_url() {
  orig_ifs=$IFS
  IFS=' '
  for argument in $@
  do
    echolog "get_curl_url, argument: $argument"                
    # The double brackets are needed otherwise the shell gets confused  
    [[ $argument =~ ^http.*$ ]] && echo "$argument" && return
  done
  IFS=$orig_ifs
  echo "Not Found"
}

get_last_curl_arguments() {
  echo "$@" | awk -F, '{ print $1 }'
}

get_last_curl_url() {
  echo "$@" | awk -F, '{ print $2 }'
}

get_last_gist_user() {
  echo "$@" | awk -F, '{ print $3 }'
}

# This is a stub/mock for the curl command it should override this and
# can be programmed here to respond in a certain way.  
curl() {
  echolog "curl stub arguments: $@"
    
  local last_curl_arguments="$@"
  local last_curl_url=$(get_curl_url $@)
  local last_gist_user=$(get_user $last_curl_url)

  echolog "curl URL: $last_curl_url"
  echolog "gist_user: $last_gist_user"

  case $last_gist_user in
    $CURL_ERROR_USER)
      last_curl_response="curl: (123) error"
      last_curl_exit_status=1
      ;;
    $EMPTY_RESPONSE_USER)
      last_curl_response=""
      last_curl_exit_status=0
      ;;    
    *)
      last_curl_response="Default"
      last_curl_exit_status=1
      ;;
  esac
  
  echolog "curl stub exit status: $last_curl_exit_status"
  echolog "curl stub response: $last_curl_response"

  # Since the curl stub is going to get called from a subprocess that
  # runs the script under test, there is no easy way to communicate
  # back to the tests.  I tried using FIFO's but these blocked the test
  # so using temp file instead as running the script is synchronous
  echo "${last_curl_arguments},${last_curl_url},${last_gist_user}" >> ${CURL_STUB_TEMP_FILENAME} 
  
  echo "$last_curl_response"
  return $last_curl_exit_status
}

# Export the function to subshells so that it works as a stub/mock
# essentially using monkey-patching
export -f curl
export -f get_curl_url
export -f get_user

