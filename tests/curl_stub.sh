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

# NOTE: Using `declare -r` doesn't seem to work and the variables
# NOTE: don't appear in the output from `set`

readonly GISTS_API_BASE_URL="https://api.github.com/users/"
readonly GISTS_API_USERS_SUFFIX="/gists"

# The users are extracted from the URL and used to direct
# how the stub will respond
readonly CURL_ERROR_USER="curlerror"
readonly EMPTY_RESPONSE_USER="empty"
readonly EMPTY_HEADER_USER="emptyheader"
readonly LESS_THAN_THIRTY_USER="lessthan30"
readonly MORE_THAN_THIRTY_USER="morethan30"

# These constants are used in the tests to trigger certain behaviour
readonly CURL_ERROR_URL=$(make_gist_url $CURL_ERROR_USER)
readonly EMPTY_RESPONSE_URL=$(make_gist_url $EMPTY_RESPONSE_USER)
readonly EMPTY_HEADER_URL=$(make_gist_url $EMPTY_HEADER_USER)
readonly LESS_THAN_THIRTY_URL=$(make_gist_url $LESS_THAN_THIRTY_USER)
readonly MORE_THAN_THIRTY_URL=$(make_gist_url $MORE_THAN_THIRTY_USER)


function get_user() {
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
function curl {
  echolog "curl stub arguments: $@"
  last_curl_arguments="$@"

  local curl_url=$(get_curl_url $@)
  local gist_user=$(get_user $curl_url)

  echolog "curl URL: $curl_url"
  echolog "gist_user: $gist_user"

  case $gist_user in
    $CURL_ERROR_USER)
      last_curl_response="curl: (123) error"
      last_curl_exit_status=1
      ;;
    *)
      last_curl_response="Default"
      last_curl_exit_status=1
      ;;
  esac
  
  echolog "curl stub exit status: $last_curl_exit_status"
  echolog "curl stub response: $last_curl_response"
  echo "$last_curl_response"
  return $last_curl_exit_status
}
