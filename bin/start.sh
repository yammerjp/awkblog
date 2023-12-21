#!/bin/bash
set -e
cd /app

function shutdown_trap() {
  echo "start to graceful shutdown"
  curl -X POST \
    -H "Authorization: bearer $PRIVATE_BEARER_TOKEN" \
    "http://localhost:${PORT:-8080}/private/shutdown"
  exit 138
}

trap shutdown_trap TERM

echo "start.sh: Build templates to src/_compiled_templates.awk"
find view/pages -type f | awk '{print substr($0, length("view/pages/") + 1)}' | awk -f bin/compile_templates.awk -v BASE_DIR=view/pages/ > src/_compiled_templates.awk

echo "start.sh: Migrate Database Schema"
/app/bin/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --file=schema.sql "$POSTGRES_DATABASE"

echo "start.sh: Start Web Application"
cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | gawk \
  $(find src/ -type f | gawk '/\.awk$/{ printf " -f %s", $0 }') \
  -v PORT="${PORT:-8080}" \
  -v OAUTH_CLIENT_ID="${OAUTH_CLIENT_ID}" \
  -v OAUTH_CLIENT_SECRET="${OAUTH_CLIENT_SECRET}" \
  -v AWKBLOG_HOSTNAME="${AWKBLOG_HOSTNAME}" \
  -v OAUTH_CALLBACK_URI="${OAUTH_CALLBACK_URI}" \
  -v GITHUB_API_SERVER="${GITHUB_API_SERVER}" \
  -v GITHUB_LOGIN_SERVER="${GITHUB_LOGIN_SERVER}" \
  -v POSTGRES_USER="${POSTGRES_USER}" \
  -v POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  -v POSTGRES_HOSTNAME="${POSTGRES_HOSTNAME}" \
  -v POSTGRES_DATABASE="${POSTGRES_DATABASE}" \
  -v POSTGRES_SSLMODE="${POSTGRES_SSLMODE}" \
  -v POSTGRES_OPTIONS="${POSTGRES_OPTIONS}" \
  -v PRIVATE_BEARER_TOKEN="${PRIVATE_BEARER_TOKEN}" \
  -v DEBUG="${DEBUG}" \
  &

  # 直接環境変数を見るように置き換え
wait
