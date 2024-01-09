#!/bin/bash

set -ex

envsubst '$$PORT $$AWKBLOG_PORT $$AWKBLOG_INTERNAL_HOSTNAME'< /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
cat /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
