#!/bin/bash

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

export ENCRYPTION_KEY="passw0rd"

find test/lib -type f | grep -e '\.awk$' | while read awkfile
do
  echo '' | gawk -f $awkfile
done
