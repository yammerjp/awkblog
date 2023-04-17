#!/bin/bash -e

set -e

cd /app

/app/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --file=schema.sql "$POSTGRES_DATABASE"

rm -f .autoload.awk
find src -type f | grep -e "\.awk$" | sort | tac | while read path;do
  echo "@include \"$path\"" >> .autoload.awk
done

./server.awk \
  -v PORT="${PORT:-8080}" \
  -v AWKBLOG_OAUTH_CLIENT_KEY="${AWKBLOG_OAUTH_CLIENT_KEY}" \
  -v AWKBLOG_OAUTH_CLIENT_SECRET="${AWKBLOG_OAUTH_CLIENT_SECRET}" \
  -v AWKBLOG_HOSTNAME="${AWKBLOG_HOSTNAME}" \
  -v POSTGRES_USER="${POSTGRES_USER}" \
  -v POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -v POSTGRES_HOSTNAME="${POSTGRES_HOSTNAME}" \
  -v POSTGRES_DATABASE="${POSTGRES_DATABASE}" \
  -v DEBUG=1 \
  < /dev/random
