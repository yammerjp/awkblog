FROM debian

RUN apt-get update -y && apt-get install -y \
  autoconf \
  automake \
  autopoint \
  gawk \
  git \
  gnutls-bin \
  libpq-dev \
  libtool \
  make \
  postgresql-client-common \
  strace \
  texinfo \
  uuid-runtime \
  curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/yammerjp/gawkextlib /gawk-pgsql/gawkextlib

WORKDIR /gawk-pgsql/gawkextlib
RUN ./build.sh lib
RUN ./build.sh pgsql --with-libpq=/usr/include/postgresql

# need apt packages "rapidjson-dev", "g++" for json extension
# RUN ./build.sh json

ENV AWKLIBPATH /usr/local/lib/gawk
ENV LD_LIBRARY_PATH /usr/local/lib
