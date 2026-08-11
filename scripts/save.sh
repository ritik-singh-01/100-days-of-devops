#!/usr/bin/env bash
# save.sh — commit and push today's learning log.
# Usage: ./scripts/save.sh "day 02: permissions and processes"

set -euo pipefail

MSG="${1:?Usage: ./scripts/save.sh \"your message\"}"

git add -A
git commit -m "$MSG"
git push
echo "Saved: $MSG"
