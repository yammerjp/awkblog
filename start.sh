#!/bin/bash -e

source ./.env

./server.awk \
  -v PORT="${PORT:-8080}" \
  -v AWKBLOG_OAUTH_CLIENT_KEY=${AWKBLOG_OAUTH_CLIENT_KEY} \
  -v AWKBLOG_OAUTH_CLIENT_SECRET=${AWKBLOG_OAUTH_CLIENT_SECRET} \
  -v AWKBLOG_HOSTNAME=${AWKBLOG_HOSTNAME} \
  < /dev/random
  # -v DEBUG=1 \
