#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT/view"

if [ "$AWKBLOG_LANG" = "ja" ]; then
    export AWKBLOG_LANGFILE="i18n/ja.yaml"
else
    export AWKBLOG_LANGFILE="i18n/en.yaml"
fi

find ./ -type f | grep -e '\.html$' | sed 's#^./##g' | awk -f ../misc/compile_templates.awk > "../src/_compiled_templates.awk"
