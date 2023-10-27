#!/bin/bash

export ENCRYPTION_KEY="passw0rd"

find test -type f | grep -e '\.awk$' | while read awkfile
do
  echo '' | gawk -f $awkfile
done
