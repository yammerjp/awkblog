#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

if [ "$AWKBLOG_WORKERS" == "" ]; then
  AWKBLOG_WORKERS=1
fi

echo "start.sh: Build templates to src/_compiled_templates.awk"
bin/compile_templates.sh

echo "start.sh: Migrate Database Schema"
/app/bin/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --config=psqldef.yml --file=schema.sql "$POSTGRES_DATABASE"

echo "start.sh: Start Web Application"

AWK_SRC_FILES=$(find src/ -type f | gawk '/\.awk$/{ printf " -f %s", $0 }')

for AWKBLOG_PORT in $(seq 40001 $((40000 + AWKBLOG_WORKERS))); do
  (
    set +e
    while true; do
      cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | AWKBLOG_PORT=$AWKBLOG_PORT gawk $AWK_SRC_FILES
      exit_code=$?
      echo "start.sh: gawk process on port $AWKBLOG_PORT exited (code $exit_code), restarting in 1s"
      sleep 1
    done
  ) &
  echo "start.sh: started gawk process, port: $AWKBLOG_PORT"
done

./bin/build_nginx_conf.sh  > /etc/nginx/conf.d/default.conf
echo "start.sh: built /etc/nginx/conf.d/default.conf"

exec nginx -g "daemon off;"
