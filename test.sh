#!/bin/bash

find test -type f | grep -e '\.awk$' | while read awkfile;do
  echo '' | awk -f $awkfile
done
