#!/bin/bash

set -e

rm -f .autoload.awk

find src -type f | grep -e "\.awk$" | grep -v "routing.awk" while read path;do
  echo "@include \"$path\"" >> .autoload.awk
done
