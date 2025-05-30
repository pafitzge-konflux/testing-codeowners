#!/bin/bash

# Usage: ./check_codeowners.sh mydir/tasks/apply-mapping some/other/dir

set -eux

if [ $# -gt 0 ]
then
  DIRECTORIES=$@
fi

if [ -z "${DIRECTORIES}" ]
then
  echo Error: No directories as argument.
  echo Usage:
  echo "$0 [item1] [item2] [...]"
  exit 1
fi

# check every item is a directory
for DIR in $DIRECTORIES
do
  if [[ -d "$DIR" ]]; then
    true
  else
    echo "Error: Not a directory: $ITEM"
    exit 1
  fi
done

for DIR in $DIRECTORIES
do

  SHORT_DIR=$(echo $DIR | cut -d '/' -f -2)
  CODEOWNERS=${SHORT_DIR}/CODEOWNERS

  if [ ! -f $CODEOWNERS ]
  then
    echo Error: CODEOWNERS file does not exist: $SHORT_DIR
    exit 1
  fi

done

gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/pafitzge-konflux/teams/sample-team/members
