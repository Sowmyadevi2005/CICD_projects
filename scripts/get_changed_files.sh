#!/usr/bin/env bash
set -euo pipefail

EVENT_NAME="$1"
BEFORE="${2:-}"
AFTER="${3:-}"
BASE_SHA="${4:-}"
HEAD_SHA="${5:-}"

files=""

if [ "$EVENT_NAME" = "push" ]; then
  # log to stderr
  >&2 echo "Push event: comparing $BEFORE..$AFTER"
  files=$(git diff --name-only --diff-filter=ACMRT "$BEFORE" "$AFTER")
elif [ "$EVENT_NAME" = "pull_request" ]; then
  >&2 echo "PR event: comparing $BASE_SHA..$HEAD_SHA"
  git fetch origin "$BASE_SHA" "$HEAD_SHA" || true
  files=$(git diff --name-only --diff-filter=ACMRT "$BASE_SHA" "$HEAD_SHA")
else
  >&2 echo "Unsupported event: $EVENT_NAME"
fi

# IMPORTANT: only paths to stdout
printf '%s\n' "$files"
