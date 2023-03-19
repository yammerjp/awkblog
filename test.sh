#!/bin/bash

export ENCRYPTION_KEY="passw0rd"

find test -type f | grep -e '\.awk$' | while read awkfile
do
  echo '' | awk -f $awkfile
done
