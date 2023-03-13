#!/usr/bin/env -S gawk -f 

@include "src/http.awk";


BEGIN {
  initialize_http();
}

!REQUEST_PROCESS {
  # start to process a request;
  start_request();
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/" {
  log_request();
  finish_request(200, NULL, "Hello, awkblog!");
}

@include "src/routing.awk"

REQUEST_PROCESS {
  log_request();
  finish_request(404, NULL, "");
}
