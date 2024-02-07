FROM ghcr.io/yammerjp/gawk-pgsql
# https://github.com/yammerjp/gawk-pgsql-docker
ARG VERSION="0.0.1-dev+with-nginx"

RUN apt-get update -y && apt-get install -y \
  uuid-runtime \
  curl \
  nginx \
  supervisor \
  gettext-base\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./ /app

RUN rm -r /var/www/html
RUN ln -sf /app/static /var/www/html

COPY ./docker/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./docker/with-nginx/supervisor.conf /etc/supervisor/conf.d/supervisord.conf

RUN /app/bin/setup.sh

RUN echo "function getAwkblogVersion() { return \""${VERSION}"\" }" > /app/src/version.awk

ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]
