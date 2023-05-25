#!/bin/bash
set -e
cd /app

echo "start.sh: Migrate Database Schema"
/app/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --file=schema.sql "$POSTGRES_DATABASE"

echo "start.sh: Start Web Application"
gawk \
  $(find src/ -type f | gawk '/\.awk$/{ printf " -f %s", $0 }') \
  -f server.awk \
  -v PORT="${PORT:-8080}" \
  -v AWKBLOG_OAUTH_CLIENT_KEY="${AWKBLOG_OAUTH_CLIENT_KEY}" \
  -v AWKBLOG_OAUTH_CLIENT_SECRET="${AWKBLOG_OAUTH_CLIENT_SECRET}" \
  -v AWKBLOG_HOSTNAME="${AWKBLOG_HOSTNAME}" \
  -v POSTGRES_USER="${POSTGRES_USER}" \
  -v POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -v POSTGRES_HOSTNAME="${POSTGRES_HOSTNAME}" \
  -v POSTGRES_DATABASE="${POSTGRES_DATABASE}" \
  -v POSTGRES_SSLMODE="${POSTGRES_SSLMODE}" \
  -v POSTGRES_OPTIONS="${POSTGRES_OPTIONS}" \
  -v DEBUG=1 \
  < /dev/random
