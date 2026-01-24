#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

curl -sL https://raw.githubusercontent.com/yammerjp/md2html/main/markdown.awk >  src/vendor/markdown.awk

# Download and convert BudouX Japanese model
curl -sL https://raw.githubusercontent.com/google/budoux/main/budoux/models/ja.json | \
  gawk -f misc/convert_budoux_model.awk > src/vendor/budoux_model_ja.awk
