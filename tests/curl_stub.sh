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
export NOT_FOUND_USER="notfound"
export LESS_THAN_THIRTY_USER="lessthan30"
export MORE_THAN_THIRTY_USER="morethan30"

# These constants are used in the tests to trigger certain behaviour
export CURL_ERROR_URL=$(make_gist_url $CURL_ERROR_USER)
export NOT_FOUND_URL=$(make_gist_url $NOT_FOUND_USER)
export LESS_THAN_THIRTY_URL=$(make_gist_url $LESS_THAN_THIRTY_USER)
export MORE_THAN_THIRTY_URL=$(make_gist_url $MORE_THAN_THIRTY_USER)


get_user() {
  local url=$1
  echo $url | sed -e "s%^${GISTS_API_BASE_URL}\(.*\)${GISTS_API_USERS_SUFFIX}.*\$%\\1%g"
}

get_query() {
  local url=$1
  echo $url | sed -e "s%^.*\?\(.*\)\$%\\1%"
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
      # Technically a valid URL like this wouldn't cause an error from curl
      # but we're just using this to trigger a response to check the behaviour
      # of the script  
      last_curl_response="curl: (123) error"
      last_curl_exit_status=1
      ;;
    $NOT_FOUND_USER)
      last_curl_response="HTTP/2 404"
      last_curl_exit_status=0
      ;;
    $LESS_THAN_THIRTY_USER)
      local query=$(get_query $last_curl_url | sed -e 's/=//g')
      echolog "lessthan30, query: $query"  
      if [[ "$query" =~ ^page ]]
      then
        data="$query"
      else
        data="header"
      fi
      data_filename="lessthan30-${data}.txt"
      echolog "lessthan, data filename: $data_filename"
      last_curl_response=$(cat tests/data/${data_filename})
      last_curl_exit_status=0
      ;;
    $MORE_THAN_THIRTY_USER)
      local query=$(get_query $last_curl_url | sed -e 's/=//g')
      echolog "lessthan30, query: $query"  
      if [[ "$query" =~ ^page ]]
      then
        data="$query"
      else
        data="header"
      fi
      data_filename="morethan30-${data}.txt"
      echolog "morethan, data filename: $data_filename"
      last_curl_response=$(cat tests/data/${data_filename})
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
export -f get_query


