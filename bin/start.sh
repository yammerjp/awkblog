#!/bin/bash
set -e
cd /app

export PORT="${PORT:-8080}"

function shutdown_trap() {
  echo "start to graceful shutdown"
  curl -X POST \
    -H "Authorization: bearer $PRIVATE_BEARER_TOKEN" \
    "http://localhost:${PORT}/private/shutdown"
  exit 138
}

trap shutdown_trap TERM

echo "start.sh: Build templates to src/_compiled_templates.awk"
find view/pages -type f | awk '{print substr($0, length("view/pages/") + 1)}' | awk -f bin/compile_templates.awk -v BASE_DIR=view/pages/ > src/_compiled_templates.awk

echo "start.sh: Migrate Database Schema"
/app/bin/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --file=schema.sql "$POSTGRES_DATABASE"

echo "start.sh: Start Web Application"
cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | gawk \
  $(find src/ -type f | gawk '/\.awk$/{ printf " -f %s", $0 }') \
  &
wait
