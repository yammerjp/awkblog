#!/bin/bash -e

set -e

cd /app

/app/psqldef --user=postgres --password=passw0rd --host=db --file=schema.sql postgres

rm -f .autoload.awk
find src -type f | grep -e "\.awk$" | sort | tac | while read path;do
  echo "@include \"$path\"" >> .autoload.awk
done

./server.awk \
  -v PORT="${PORT:-8080}" \
  -v AWKBLOG_OAUTH_CLIENT_KEY="${AWKBLOG_OAUTH_CLIENT_KEY}" \
  -v AWKBLOG_OAUTH_CLIENT_SECRET="${AWKBLOG_OAUTH_CLIENT_SECRET}" \
  -v AWKBLOG_HOSTNAME="${AWKBLOG_HOSTNAME}" \
  -v DEBUG=1 \
  < /dev/random
