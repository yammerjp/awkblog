#!/usr/bin/env -S gawk -f 

@include ".autoload.awk"

BEGIN {
  print "Start awkblog. listen port " PORT " ..."
  http::initialize_http();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::start_request();
}

@include "./routing.awk"
