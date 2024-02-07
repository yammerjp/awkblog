#!/bin/bash

set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

echo "misc/nginx.default.conf.template" | gawk -f misc/compile_templates.awk > /tmp/nginx.default.conf.template.awk
gawk -f /tmp/nginx.default.conf.template.awk -f <(echo 'BEGIN {printf "%s", compiled_templates::render("misc/nginx.default.conf.template")}')


