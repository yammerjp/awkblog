#!/bin/bash

REPOSITORY_ROOT="$(dirname "$0")/.."
cd "$REPOSITORY_ROOT"

export ENCRYPTION_KEY="passw0rd"
export OAUTH_CLIENT_ID=xxxx
export OAUTH_CLIENT_SECRET=xxxx
export AWKBLOG_HOSTNAME="http://localhost:4567"
export POSTGRES_HOSTNAME=db
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=passw0rd
export POSTGRES_DATABASE=postgres
export OAUTH_CALLBACK_URI="http://localhost:4567/oauth-callback"
export GITHUB_API_SERVER="https://api.github.com"
export GITHUB_LOGIN_SERVER="https://github.com"
export AWS_REGION=ap-northeast-1
export AWS_BUCKET=bucketname
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx
export S3_BUCKET_ENDPOINT="https://bucketname.s3.amazonaws.com"
export S3_ASSET_HOST="https://bucketname.s3.amazonaws.com"
export PORT="4567"
export AWKBLOG_PORT="4568"
export AWKBLOG_INTERNAL_HOSTNAME="127.0.0.1"


find test/lib -type f | grep -e '\.awk$' | while read awkfile
do
  echo '' | gawk -f $awkfile
done
