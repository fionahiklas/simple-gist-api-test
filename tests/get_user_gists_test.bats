#!/usr/bin/env bats
#
# -*- mode: bats-mode; -*-
#

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

  cat $CURL_STUB_TEMP_FILENAME
  
  echolog "check stub, curl exit status: $function_status"
  echolog "check stub, curl response: $function_output"
  [ "$function_status" -eq 1 ]
  [[ "$function_output" =~ ^curl: ]]
}

@test "Run get_user_gists script without arguments" {
  run test_script
  [ "$status" -eq 1 ]
  echolog "lines: $output"
  [[ "$lines[0]" =~ ^Usage: ]]
}

@test "Run get_user_gists script with user and curl called" {
  run test_script -u $EMPTY_RESPONSE_USER
  echolog "run command: $BATS_RUN_COMMAND"  
  echolog "status: $status"
  echolog "output: $output"
  [ "$status" -eq 0 ]
  # TODO: These won't get updated as they are in a sub-shell
  #[ "$curl_stub_call_count" -eq 1 ]
  #[ "$last_curl_url" = "$EMPTY_RESPONSE_URL" ]
}
