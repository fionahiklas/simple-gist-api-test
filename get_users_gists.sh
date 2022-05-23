#!/usr/bin/env sh
#
# -*- mode: shell-script; -*-
#

while getopts ":u" option; do
  case "${option}" in
    u)
      USERNAME=$OPTARG
      ;;
  esac
done

[ "$USERNAME" = "" ] && echo "Usage: get_users_gists.sh -u <username>" && exit 1




