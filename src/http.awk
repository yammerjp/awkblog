@load "ordchr"

function receive_request(    line, splitted, content_length, readcharlen) {
  delete HTTP_REQUEST
  # read first line
  RS="\n"
  INET |& getline line;
  split(line, splitted," ");
  HTTP_REQUEST["method"] = splitted[1];
  HTTP_REQUEST["path"] = splitted[2];

  content_length = 0

  # read HTTP header
  for(i = 1; INET |& getline line > 0; i++) {
    if (line ~ /^Content-Length: /) {
      split(line, splitted, " ")
      content_length = splitted[2]
    }
    if (line == "" || line == "\r") {
      break;
    }
    HTTP_REQUEST["header"][i] = line;
  }

  # read HTTP body
  HTTP_REQUEST["body"][1] = ""
  while(content_length > 1) {
    if (content_length <= 1000) {
      readcharlen = content_length - 1
    } else {
      readcharlen = 1000
    }
    RS = sprintf(".{%d}", readcharlen)
    INET |& getline
    HTTP_REQUEST["body"][1] = HTTP_REQUEST["body"][1] RT
    content_length -= readcharlen
  }
  RS="\n"
}

function http_response_status(status_num) {
  switch(status_num) {
    case 200: return "200 OK";
    case 204: return "204 OK";
    case 404: return "404 Not Found";
    default:  return "500 Not Handled";
  }
}

function build_http_response(status_num, headers, content,    header_str) {
  if (isarray(headers)) {
    for (i in headers) {
      header_str = headers[i] "\n";
    }
  }
  return sprintf("HTTP/1.1 %s\n%s\n%s", http_response_status(status_num), header_str, content);
}

function send_response(status_num, headers, content) {
  printf "%s", build_http_response(status_num, headers, content) |& INET;
  close(INET);
}

function log_request() {
  print "request: ";
  print "  method:";
  print "    " HTTP_REQUEST["method"];
  print "  path:";
  print "    " HTTP_REQUEST["path"];
  print "  header:";
  HTTP_REQUEST["header"][0] = ""
  delete HTTP_REQUEST["header"][0]
  for (i in HTTP_REQUEST["header"]) {
    print "    " HTTP_REQUEST["header"][i];
  }
  print "  body:";
  HTTP_REQUEST["body"][0] = ""
  delete HTTP_REQUEST["body"][0]
  for (i in HTTP_REQUEST["body"]) {
    print "    " HTTP_REQUEST["body"][i];
  }
  print "";
}

function initialize_http() {
  INET = "/inet/tcp/" PORT "/0/0";
  FS=""
  REQUEST_PROCESS = 0;
}

function finish_request(status_num, headers, content) {
  send_response(status_num, headers, content);
  REQUEST_PROCESS = 0;
  next;
}

function start_request() {
  $0 = "";
  receive_request();
  REQUEST_PROCESS = 1;
}
