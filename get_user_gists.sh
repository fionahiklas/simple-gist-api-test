#!/usr/bin/env bash
#
# -*- mode: shell-script; -*-
#

readonly GISTS_API_BASE_URL="https://api.github.com/users/"
readonly GISTS_API_USERS_SUFFIX="/gists"

while getopts "u:" option; do
  case "${option}" in
    u)
      USERNAME=$OPTARG
      ;;
  esac
done

[ "$USERNAME" = "" ] && echo "Usage: get_users_gists.sh -u <username>" && exit 1

header_response=$(curl -I "${GISTS_API_BASE_URL}${USERNAME}${GISTS_API_USERS_SUFFIX}")
found=$(echo "$header_response" | grep "HTTP/2 200")

if [ "$found" = "" ]
then
  echo "User not found"
  exit 1 
fi  

curl  "${GISTS_API_BASE_URL}${USERNAME}${GISTS_API_USERS_SUFFIX}?page=1"
