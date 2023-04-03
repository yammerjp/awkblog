#!/usr/bin/env -S gawk -f 

@include ".autoload.awk"

BEGIN {
  query = "SELECT id, name FROM accounts WHERE id = $1 AND name = $2;"
  params[1] = "29299532"
  params[2] = "yammerjp"
  pgsql::create_connection()
  pgsql::exec(query, params)
  print "rows: " pgsql::fetch_rows()
  print "id: " pgsql::fetch_result(0, "id")
  print "name: " pgsql::fetch_result(0, "name")

  # exit 0

  print "Start awkblog. listen port " PORT " ..."
  http::initialize_http();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::start_request();
}

@include "./routing.awk"
