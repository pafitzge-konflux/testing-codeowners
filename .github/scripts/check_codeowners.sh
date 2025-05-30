#!/bin/bash

# Usage: ./check_codeowners.sh mydir/tasks/apply-mapping some/other/dir

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
  CODEOWNERS=${SHORT_DIR}/CODEOWNERS

  if [ ! -f $CODEOWNERS ]; then
    echo Error: CODEOWNERS file does not exist: $SHORT_DIR
    exit 1
  fi

done

NEW_CODEOWNERS=$(mktemp)

cat .github/CODEOWNERS > $NEW_CODEOWNERS

ORGANISATION=pafitzge-konflux
TEAM_NAME=sample-team

# This GitHub API call will require a token with the read:org permission
TEAM_MEMBERS=$(gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /orgs/$ORGANISATION/teams/$TEAM_NAME/members | jq -r .[].login)

for DIR in $DIRECTORIES
do

  SHORT_DIR=$(echo $DIR | cut -d '/' -f -2)
  CODEOWNERS=${SHORT_DIR}/CODEOWNERS

  REGEX="(^|\s)@sample-team($|\s)"

  if [[ $(cat $CODEOWNERS) =~ $REGEX ]]; then
    echo "Error: $TEAM_NAME cannot be" \
      "included as a code owner."
    exit 1 
  fi

  for MEMBER in $TEAM_MEMBERS
  do
    REGEX="(^|\s)@$MEMBER($|\s)"

    if [[ $(cat $CODEOWNERS) =~ $REGEX ]]; then
      echo "Error: members of $TEAM_NAME" \
        "cannot be included as a code owner."
      exit 1 
    fi
  done

  echo "$CODEOWNERS exists and does not contain $TEAM_NAME" \
    "or any of its members"

  cat $CODEOWNERS >> $NEW_CODEOWNERS
done

cat $NEW_CODEOWNERS > .github/CODEOWNERS
