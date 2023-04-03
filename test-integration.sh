#!/bin/bash

export ENCRYPTION_KEY="passw0rd"

find test/integration -type f | grep -e '\.yaml$' | xargs runn run
