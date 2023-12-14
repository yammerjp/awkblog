#!/bin/bash

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

export ENCRYPTION_KEY="passw0rd"

find test/integration -type f | grep -e '\.yaml$' | xargs runn run
