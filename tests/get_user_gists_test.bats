#!/usr/bin/env bats
#
# -*- mode: bats-mode; -*-
#

# We need to use the --separate-stderr flag on run and this
# needs at least version 1.5.0 of Bats
bats_require_minimum_version 1.5.0

load helper_functions.sh
load curl_stub.sh

setup() {
  export CURL_STUB_TEMP_FILENAME=$(mktemp)
  echolog "created temp file: $CURL_STUB_TEMP_FILENAME"
}

teardown() {
  echolog "removing temp file: $CURL_STUB_TEMP_FILENAME"
  rm $CURL_STUB_TEMP_FILENAME
}

# This function is needed to ensure that bash is used to run the
# script under test as it's the only shell that supports export/import
# of functions and we need that to be able to mock/stub curl
test_script() {
  bash get_user_gists.sh "$@"
}

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
  # This outputs ALOT, only use for debugging
  #echolog "Result $result"
  
  # It seems that having these expressions without the && passes
  # no matter what result contains.  This is because this whole
  # construct is forming the last expression in the function
  # (test) which is the return value
  [[ "$result" =~ CURL_ERROR_URL ]] &&
  [[ "$result" =~ NOT_FOUND_URL ]] &&
  [[ "$result" =~ LESS_THAN_THIRTY_URL ]] &&
  [[ "$result" =~ MORE_THAN_THIRTY_URL ]]
}

@test "Check stub responds correctly for error url" {

  wrap_failing_function curl $CURL_ERROR_URL

  local stub_calls=$(cat $CURL_STUB_TEMP_FILENAME)
  echolog "stub_calls: $stub_calls"
  echolog "check stub, curl exit status: $function_status"
  echolog "check stub, curl response: $function_output"
  
  [ "$stub_calls" = "https://api.github.com/users/curlerror/gists,https://api.github.com/users/curlerror/gists,curlerror" ]
  [ "$function_status" -eq 1 ]

  # This only works as a test because it's at the end of the function
  # and is effectively the function exit status 
  [[ "$function_output" =~ ^curl: ]]
}

@test "Check stub responds correctlyfor less than 30 url" {

  wrap_failing_function curl $LESS_THAN_THIRTY_URL

  local stub_calls=$(cat $CURL_STUB_TEMP_FILENAME)
  echolog "stub_calls: $stub_calls"
  echolog "check stub, curl exit status: $function_status"
  echolog "check stub, curl response: $function_output"
  
  [ "$stub_calls" = "https://api.github.com/users/lessthan30/gists,https://api.github.com/users/lessthan30/gists,lessthan30" ]
  [ "$function_status" -eq 0 ]

  # This only works as a test because it's at the end of the function
  # and is effectively the function exit status 
  [[ "$function_output" =~ ^HTTP/2\ 200 ]]
}

@test "Check stub responds correctlyfor less than 30 url with page=1" {

  wrap_failing_function curl "${LESS_THAN_THIRTY_URL}?page=1"

  local stub_calls=$(cat $CURL_STUB_TEMP_FILENAME)
  echolog "stub_calls: $stub_calls"
  echolog "check stub, curl exit status: $function_status"
  echolog "check stub, curl response: $function_output"
  
  [ "$stub_calls" = "https://api.github.com/users/lessthan30/gists?page=1,https://api.github.com/users/lessthan30/gists?page=1,lessthan30" ]
  [ "$function_status" -eq 0 ]
}


@test "Run get_user_gists script without arguments" {
  run --separate-stderr test_script
  [ "$status" -eq 1 ]
  echolog "lines: $output"

  # This only works as a test because it's at the end of the function
  # and is effectively the function exit status   
  [[ "${lines[0]}" =~ ^Usage: ]]
}

@test "Run get_user_gists script user not found" {
  run --separate-stderr test_script -u $NOT_FOUND_USER
  echolog "run command: $BATS_RUN_COMMAND"  
  echolog "status: $status"
  echolog "output: $output"
  echolog "lines[0]: ${lines[0]}"
  
  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ ^User\ not\ found ]] || return 1
  
  local stub_calls=$(cat $CURL_STUB_TEMP_FILENAME)
  echolog "stub_calls: ${stub_calls}"

  local number_of_calls=$(echo "${stub_calls}" | wc -l)
  [ "$number_of_calls" -eq 1 ]

  local curl_arguments=$(get_last_curl_arguments "$stub_calls")
  local curl_url=$(get_curl_url "$curl_arguments")

  echolog "curl_arguments: $curl_arguments"
  echolog "curl_url: $curl_url"
  
  [[ "$curl_arguments" =~ ^\-I ]] || return 1
  [ "$curl_url" = "$NOT_FOUND_URL" ]
  return 0
}

@test "Run get_user_gists script user returns less than 30 results" {
  run --separate-stderr test_script -u $LESS_THAN_THIRTY_USER
  echolog "run command: $BATS_RUN_COMMAND"  
  echolog "status: $status"
  
  [ "$status" -eq 0 ]
  
  local stub_calls=$(cat $CURL_STUB_TEMP_FILENAME)
  echolog "stub_calls: ${stub_calls}"

  local number_of_calls=$(echo "${stub_calls}" | wc -l)
  echolog "number of stub_calls: ${number_of_calls}"
  [ "$number_of_calls" -eq 2 ]
  return 0
}

