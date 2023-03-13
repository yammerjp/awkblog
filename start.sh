#!/bin/bash -e

source ./.env

src/server.awk \
  -v PORT="${PORT:-8080}" \
  < /dev/random
  # -v DEBUG=1 \
