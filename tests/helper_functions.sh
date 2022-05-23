#!/usr/bin/env bash
#
# -*- mode: shell-mode; -*-
#

# Ensure that logging goes to STDERR to that
# STDOUT can be captures for return values and
# the logs will be displayed with verbose setting
# for bats, --show-output-of-passing-tests
function echolog() { echo "LOG: $@" 1>&2; }

# Global variables set when the function runs
function_status=0
function_output=""

function wrap_failing_function {
  original_flags=$-
  set +eET
  function_output=$($@)
  function_status=$?
  set -"$original_flags"
}

# Need to export the functions so they are available
# in subshells
export -f echolog
