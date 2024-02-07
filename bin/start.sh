#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

export PRIVATE_BEARER_TOKEN="$(echo "$(date +%s%N)$POSTGRES_PASSWORD" | sha256sum | awk '{print $1}')"

function shutdown_trap() {
  echo "start to graceful shutdown"
  for AWKBLOG_PORT in $(seq 40001 40040); do
    curl -X POST \
      -H "Authorization: bearer $PRIVATE_BEARER_TOKEN" \
      "http://localhost:${AWKBLOG_PORT:$PORT}/private/shutdown"
    echo "stopped gawk process, port: $AWKBLOG_PORT"
  done

  exit 138
}

trap shutdown_trap TERM

echo "start.sh: Build templates to src/_compiled_templates.awk"
bin/compile_templates.sh

echo "start.sh: Migrate Database Schema"
/app/bin/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --file=schema.sql "$POSTGRES_DATABASE"

echo "start.sh: Start Web Application"

for AWKBLOG_PORT in $(seq 40001 40040); do
  cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | AWKBLOG_PORT=$AWKBLOG_PORT gawk \
    $(find src/ -type f | gawk '/\.awk$/{ printf " -f %s", $0 }') \
    &
    echo "started gawk process, port: $AWKBLOG_PORT"
done

wait
