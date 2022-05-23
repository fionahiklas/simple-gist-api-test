#!/usr/bin/env bats
#
# -*- mode: bats-mode; -*-
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

function curl() {
  echo ""
}

@test "Check curl URL" {
  TEST_URL=https://some.url.domain.here
  local result=$(get_curl_url -I -H "Wibble: wibble" $TEST_URL)
  echolog "Result: $result"
  [ "$result" = "$TEST_URL" ]  
}


@test "Run get_user_gists script without arguments" {
  run ./get_users_gists.sh
  [ "$status" -eq 1 ]
  [[ "$lines[0]" =~ ^Usage: ]]
}

