@load "ordchr"

function start_request(    line, splitted, content_length, readcharlen) {
  $0 = "";

  delete HTTP_REQUEST
  # read first line
  RS="\n"
  INET |& getline line;
  if (line !~ /^\(HEAD|GET|POST|PUT|DELETE|OPTIONS|PATCH\) \/.* HTTP\/1\.1$/) {
    finish_request(400)
    return
  }
  split(line, splitted,"[ ?]");
  HTTP_REQUEST["method"] = splitted[1];
  HTTP_REQUEST["path"] = splitted[2];
  HTTP_REQUEST["parameters"] = splitted[3];

  content_length = 0

  # read HTTP header
  for(i = 1; INET |& getline line > 0; i++) {
    if (line ~ /^Content-Length: /) {
      content_length = substr(line, 17)
    }

    if (line == "" || line == "\r") {
      break;
    }
    HTTP_REQUEST["header"][i] = line;
  }

  # read HTTP body
  HTTP_REQUEST["body"] = ""
  while(content_length > 1) {
    if (content_length > 1000) {
      readcharlen = 1000
    } else {
      readcharlen = content_length - 1
    }
    RS = sprintf(".{%d}", readcharlen)
    INET |& getline
    HTTP_REQUEST["body"] = HTTP_REQUEST["body"] RT
    content_length -= readcharlen
  }
  RS="\n"
  parse_request()
  log_request()

  REQUEST_PROCESS = 1;
}

function parse_request() {
  delete HTTP_REQUEST_HEADERS
  for(i in HTTP_REQUEST["header"]) {
    line = HTTP_REQUEST["header"][i]
    colon_space = index(line, ": ")
    key = substr(line, 1, colon_space)
    value = substr(line, colon_space+2)
    HTTP_REQUEST_HEADERS[key] = value
  }

  delete COOKIES
  split(HTTP_REQUEST_HEADERS["Cookie"], splitted, ";")
  for(i in splitted) {
    idx = index(splitted[i], "=")
    key = substr(splitted[i], 1, idx)
    value = substr(splitted[i], idx+1)
    if (value ~ "^\".*\"$") {
      value = substr(value, 2, length(value) - 2)
    }
    COOKIES[key] = value
  }
  delete HTTP_REQUEST_PARAMETERS
  
  if (length(HTTP_REQUEST["parameters"]) > 0) {
    decode_www_form(HTTP_REQUEST["parameters"])
  }
  for (i in KV) {
    HTTP_REQUEST_PARAMETERS[i] = KV[i]
  }
}

function finish_request(status_num, content) {
  printf "%s", build_http_response(status_num, content) |& INET;
  close(INET);
  REQUEST_PROCESS = 0;
  delete HTTP_RESPONSE_HEADERS
  next;
}

function build_http_response(status_num, content,    header_str, status) {
  
  switch(status_num) {
    case 200: status = "200 OK"; break;
    case 204: status = "204 OK"; break;
    case 302: status = "302 Found"; break;
    case 404: status = "404 Not Found"; break;
    default:  status = "500 Not Handled";break;
  }

  for(i in HTTP_RESPONSE_HEADERS) {
    header_str = header_str i ": " HTTP_RESPONSE_HEADERS[i] "\n";
  }
  cookies = ""
  for (i in COOKIES) {
    if (i != "" && COOKIES[i] != "") {
      cookies = cookies i "=" COOKIES[i] ";"
    }
  }
  if (cookies != "") {
    header_str = header_str cookies "\n"
  }
  return sprintf("HTTP/1.1 %s\n%s\n%s", status, header_str, content);
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
  if (HTTP_REQUEST["body"] != "") {
    print "  body:";
    print "    " HTTP_REQUEST["body"];
  }
  print "";
}

function get_cookie(key) {
  for(i in COOKIES) {
    if (i == key) {
      return key
    }
  }
  return ""
}

function initialize_http() {
  INET = "/inet/tcp/" PORT "/0/0";
  FS=""
  REQUEST_PROCESS = 0;
}

function render_html(status_num, content,  headers) {
  HTTP_RESPONSE_HEADERS["Content-Type"] = "text/html; charset=UTF-8"
  finish_request(status_num, content)
}

function redirect302(url) {
  HTTP_RESPONSE_HEADERS["Location"] = url
  finish_request(302, "");
}
