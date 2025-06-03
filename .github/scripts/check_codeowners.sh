#!/bin/bash

# Usage: ./check_OWNERS.sh mydir/tasks/apply-mapping some/other/dir
# This script will check for an OWNERS file in all task and pipeline 
# directories provided either via DIRECTORIES env var, or as 
# arguments when running the script.
#
# Requirements:
# - A GitHub token with permission to read members of a team in
#   a organisation.
#
# Examples of usage:
# export DIRECTORIES="mydir/tasks/apply-mapping some/other/dir"
# ./check_OWNERS.sh
#
# or
#
# ./check_OWNERS.sh mydir/tasks/apply-mapping some/other/dir

set -eux

if [ $# -gt 0 ]; then
  DIRECTORIES=$@
fi

if [ -z "${DIRECTORIES}" ]; then
  echo Error: No directories as argument.
  echo Usage:
  echo "$0 [item1] [item2] [...]"
  exit 1
fi

# check every item is a directory
for DIR in $DIRECTORIES; do
  if [[ -d "$DIR" ]]; then
    true
  else
    echo "Error: Not a directory: $DIR"
    exit 1
  fi
done

for DIR in $DIRECTORIES
do

  SHORT_DIR=$(echo $DIR | cut -d '/' -f -2)
  OWNERS=${SHORT_DIR}/OWNERS

  if [ ! -f $OWNERS ]; then
    echo Error: OWNERS file does not exist: $SHORT_DIR
    exit 1
  fi

done

ORGANISATION=pafitzge-konflux
TEAM_NAME=sample-team

# This GitHub API call requires a token with permission to read
# members of a team
TEAM_MEMBERS=$(gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/$ORGANISATION/teams/$TEAM_NAME/members | jq -r .[].login)

for DIR in $DIRECTORIES
do

  SHORT_DIR=$(echo $DIR | cut -d '/' -f -2)
  OWNERS=${SHORT_DIR}/OWNERS

  REGEX="(\s)$TEAM_NAME($|\s)"

  if [[ $(cat $OWNERS) =~ $REGEX ]]; then
    echo "Error: $TEAM_NAME cannot be" \
      "included as a code owner."
    exit 1 
  fi

  for MEMBER in $TEAM_MEMBERS
  do
    REGEX="(^|\s)$MEMBER($|\s)"

    if [[ $(cat $OWNERS) =~ $REGEX ]]; then
      echo "Error: members of $TEAM_NAME" \
        "cannot be included as a code owner."
      exit 1
    fi
  done

  echo "$OWNERS exists and does not contain $TEAM_NAME" \
    "or any of its members"

done
