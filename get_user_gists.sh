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

readonly DATE_FILENAME=".gist_date_${USERNAME}"

header_response=$(curl -I "${GISTS_API_BASE_URL}${USERNAME}${GISTS_API_USERS_SUFFIX}" 2> /dev/null)
found=$(echo "$header_response" | grep "HTTP/2 200")

if [ "$found" = "" ]
then
  echo "User not found"
  exit 1 
fi  

link_line=$(echo "$header_response" | grep "link: ")

if [ "$link_line" = "" ]
then
  page_range=1
else
  last_page=$(echo "$link_line" | awk -F, '{print $2}' | sed 's/^.*?page=\([0-9]*\).*$/\1/')
  page_range=$(seq $last_page)  
fi

# Starts off empty in case we have no timestamp file saved
since_query_param=""

# Read in timestamp
if [ -f "$DATE_FILENAME" ]
then
  since_timestamp=$(cat $DATE_FILENAME)
  since_query_param="&since=$since_timestamp"
  echo "Using since query parameter for filename ${DATE_FILENAME}"
fi

for page_value in $page_range
do
  curl  "${GISTS_API_BASE_URL}${USERNAME}${GISTS_API_USERS_SUFFIX}?page=${page_value}${since_query_param}" 2> /dev/null | jq -r '. | map([.url, .description] | join(",")) | join("\n")' 
done   

# Output last timestamp we ran this
date -Iseconds > $DATE_FILENAME
echo "Saved since parameter into ${DATE_FILENAME}"

