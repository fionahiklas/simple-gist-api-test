#!/usr/bin/env bats
#
# -*- mode: bats-mode; -*-
#

load helper_functions.sh
load curl_stub.sh

@test "Check curl URL" {
  TEST_URL=https://some.url.domain.here
  local result=$(get_curl_url -I -H "Wibble: wibble" $TEST_URL)
  echolog "Result: $result"
  [ "$result" = "$TEST_URL" ]  
}

@test "Check environment" {
  # This set command syntax/option "posix" doesn't work on zsh
  # but does on bash   
  local result=$(set -o posix; set)
  #echolog "Result $result"
  
  # It seems that having these expressions without the && passes
  # no matter what result contains.  Not sure why this is the case
  [[ "$result" =~ CURL_ERROR_URL ]] &&
  [[ "$result" =~ EMPTY_RESPONSE_URL ]] &&
  [[ "$result" =~ EMPTY_HEADER_URL ]] &&
  [[ "$result" =~ LESS_THAN_THIRTY_URL ]] &&
  [[ "$result" =~ MORE_THAN_THIRTY_URL ]]
}

@test "Check stub responds correctly" {

  wrap_failing_function curl $CURL_ERROR_URL
  
  echolog "check stub, curl exit status: $function_status"
  echolog "check stub, curl response: $function_output"
  [ "$function_status" -eq 1 ]
  [[ "$function_output" =~ ^curl: ]]
}

@test "Run get_user_gists script without arguments" {
  run ./get_user_gists.sh
  [ "$status" -eq 1 ]
  [[ "$lines[0]" =~ ^Usage: ]]
}

