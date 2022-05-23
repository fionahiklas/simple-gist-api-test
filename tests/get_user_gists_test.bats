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


@test "Run get_user_gists script without arguments" {
  run ./get_user_gists.sh
  [ "$status" -eq 1 ]
  [[ "$lines[0]" =~ ^Usage: ]]
}

