#!/usr/bin/env -S gawk -f 

@include ".autoload.awk"

BEGIN {
  pgsql::createConnection()

  query = "SELECT count(id) as rows FROM posts;"
  params[1] = ""
  pgsql::exec(query, params)
  print "Database Healthcheck: count(posts.id) ... " pgsql::fetchResult(0, "name")

  print "Start awkblog. listen port " PORT " ..."
  http::initializeHttp();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::receiveRequest();
}

@include "./routing.awk"
