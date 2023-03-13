#!/bin/bash -e

source ./.env

src/server.awk \
  -v PORT="${PORT:-8080}" \
  -v AWKBLOG_OAUTH_CLIENT_KEY=${AWKBLOG_OAUTH_CLIENT_KEY} \
  -v AWKBLOG_HOSTNAME=${AWKBLOG_OAUTH_CLIENT_KEY} \
  < /dev/random
  # -v DEBUG=1 \
