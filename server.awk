#!/usr/bin/env -S gawk -f 

@include ".autoload.awk"

BEGIN {
  print "Start awkblog. listen port " PORT " ..."
  initialize_http();
}

!REQUEST_PROCESS {
  # start to process a request;
  start_request();
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/" {
  finish_request(200, NULL, "Hello, awkblog!");
}

@include "src/routing.awk"

REQUEST_PROCESS {
  finish_request(404, NULL, "");
}
