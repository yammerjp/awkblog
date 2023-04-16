FROM ghcr.io/yammerjp/gawk-pgsql
# https://github.com/yammerjp/gawk-pgsql-docker

RUN apt-get update -y && apt-get install -y \
  uuid-runtime \
  curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./ /app
