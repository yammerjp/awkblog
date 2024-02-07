#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT/view"

find ./ -type f | sed 's#^./##g' | awk -f ../misc/compile_templates.awk > "../src/_compiled_templates.awk"
