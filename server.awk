#!/usr/bin/env -S gawk -f 

@include ".autoload.awk"

BEGIN {
  pgsql::createConnection()

  # query = "SELECT id, name FROM accounts WHERE id = $1 AND name = $2;"
  # params[1] = "29299532"
  # params[2] = "yammerjp"
  # pgsql::exec(query, params)
  # print "rows: " pgsql::fetchRows()
  # print "id: " pgsql::fetchResult(0, "id")
  # print "name: " pgsql::fetchResult(0, "name")

  # query = "SELECT id, name FROM accounts ;"
  # pgsql::exec(query)
  # print "rows: " pgsql::fetchRows()
  # print "id: " pgsql::fetchResult(0, "id")
  # print "name: " pgsql::fetchResult(0, "name")

  print "Start awkblog. listen port " PORT " ..."
  http::initializeHttp();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::receiveRequest();
}

@include "./routing.awk"
