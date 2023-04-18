#!/usr/bin/env -S gawk -f 

@include ".autoload.awk"

BEGIN {
  pgsql::createConnection()

  query = "SELECT count(id) as ids FROM posts;"
  pgsql::exec(query)
  rows = pgsql::fetchRows()
  print "Database Healthcheck: count(posts.id) (rows:" rows ") ... " pgsql::fetchResult(0, "ids")

  print "Start awkblog. listen port " PORT " ..."
  http::initializeHttp();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::receiveRequest();
}

@include "./routing.awk"
