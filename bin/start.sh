#!/bin/bash
set -e

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

if [ "$WORKERS" == "" ]; then
  WORKERS=1
fi

# function shutdown_trap() {
#   echo "start.sh: shutdown_trap()"
#   exit 100
# }
# 
# trap shutdown_trap SIGTERM



echo "start.sh: Build templates to src/_compiled_templates.awk"
bin/compile_templates.sh

echo "start.sh: Migrate Database Schema"
/app/bin/psqldef --user="$POSTGRES_USER" --password="$POSTGRES_PASSWORD" --host="$POSTGRES_HOSTNAME" --file=schema.sql "$POSTGRES_DATABASE"

echo "start.sh: Start Web Application"

for AWKBLOG_PORT in $(seq 40001 $((40000 + WORKERS))); do
  cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | AWKBLOG_PORT=$AWKBLOG_PORT gawk \
    $(find src/ -type f | gawk '/\.awk$/{ printf " -f %s", $0 }') \
    &
    echo "start.sh: started gawk process, port: $AWKBLOG_PORT"
done

./bin/build_nginx_conf.sh  > /etc/nginx/conf.d/default.conf
echo "start.sh: built /etc/nginx/conf.d/default.conf"

exec nginx -g "daemon off;"

# pwait
