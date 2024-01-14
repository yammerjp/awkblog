FROM nginx

RUN apt-get update -y && apt-get install -y \
  gettext-base \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./docker/nginx/start-nginx.sh /start-nginx.sh
COPY ./docker/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template

STOPSIGNAL SIGQUIT

RUN mkdir /var/tmp/nginx;

ENTRYPOINT /start-nginx.sh
