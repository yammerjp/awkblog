#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT/view"

find pages -type f | gawk -f ../lib/compile_templates.awk > "../src/_compiled_templates.awk"
