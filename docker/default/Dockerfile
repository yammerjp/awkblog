FROM ghcr.io/yammerjp/gawk-pgsql
# https://github.com/yammerjp/gawk-pgsql-docker
ARG VERSION="0.0.1-dev"

RUN apt-get update -y && apt-get install -y \
  uuid-runtime \
  curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./ /app

RUN /app/bin/setup.sh
RUN echo "function getAwkblogVersion() { return \""${VERSION}"\" }" > /app/src/version.awk

ENTRYPOINT [ "/app/bin/start.sh" ]
