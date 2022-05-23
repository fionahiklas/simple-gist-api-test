#!/usr/bin/env bats
#
# -*- mode: bats-mode; -*-
#

function finduser() {
  echo ""
}

function get_curl_url {
  for argument in $@
  do
    # The double brackets are needed otherwise the shell gets confused  
    [[ $argument =~ ^httd.*$ ]] && echo "$argument" && break
  done
  echo "Not Found"
}

function curl() {
  echo ""
}

@test "Check curl URL" {
  TEST_URL=https://some.url.domain.here
  local result=$(get_curl_url -I -H "Wibble: wibble" $TEST_URL)
  [ "$result" = "$TEST_URL" ]  
}


@test "Run get_user_gists script" {
  run ./get_users_gists.sh
}

