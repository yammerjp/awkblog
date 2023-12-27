#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

curl -sL https://raw.githubusercontent.com/yammerjp/md2html/main/markdown.awk >  src/vendor/markdown.awk
