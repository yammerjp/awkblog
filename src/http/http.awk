@namespace "http"

function http::IS_STARTS_WITH(method, path_prefix,        path) {
  if (!REQUEST_PROCESS || HTTP_REQUEST["method"] != method) {
    return 0
  }
  path = HTTP_REQUEST["path"]
  if (length(path_prefix) > length(path)) {
    return 0
  }
  return substr(path, 1, length(path_prefix)) == path_prefix
}

function http::IS(method, path) {
  return REQUEST_PROCESS && HTTP_REQUEST["method"] == method && (HTTP_REQUEST["path"] == path || HTTP_REQUEST["path"] == path "/")
}

function http::IS_ANY() {
  return REQUEST_PROCESS
}

function startRequest(    line, splitted, content_length, readcharlen, leftover) {
  $0 = "";

  delete HTTP_REQUEST
  # read first line
  awk::RS="\n"
  INET |& getline line;
  if (line !~ /^\(HEAD|GET|POST|PUT|DELETE|OPTIONS|PATCH\) \/.* HTTP\/1\.1$/) {
    finishRequest(400)
    return
  }
  split(line, splitted,"[ ?]");
  HTTP_REQUEST["method"] = splitted[1];
  HTTP_REQUEST["path"] = splitted[2];
  HTTP_REQUEST["parameters"] = splitted[3];
  HTTP_REQUEST["version"] = splitted[4];

  content_length = 0

  # read HTTP header
  for(i = 1; INET |& getline line > 0; i++) {
    if (line == "" || line == "\r") {
      break;
    }
    gsub(/\r/, "" , line)
    HTTP_REQUEST["header"][i] = line;

    if (line ~ /^Content-Length: /) {
      content_length = int(substr(line, 17))
    }
  }

  # read HTTP body
  HTTP_REQUEST["body"] = ""

  # The end of the body is not read;\if the entire body is tried to be read, the operation is stalled due to waiting for the next input after the last character.
  leftover = 1

  while(content_length > leftover) {
    if (content_length > 1000) {
      readcharlen = 1000
    } else {
      readcharlen = content_length - leftover
    }
    awk::RS = sprintf(".{%d}", readcharlen)
    INET |& getline
    HTTP_REQUEST["body"] = HTTP_REQUEST["body"] awk::RT
    content_length -= readcharlen
  }
  awk::RS="\n"
  parseRequest()
  log_request()

  REQUEST_PROCESS = 1;
}

function parseRequest() {
  delete HTTP_REQUEST_HEADERS
  for(i in HTTP_REQUEST["header"]) {
    line = HTTP_REQUEST["header"][i]
    colon_space = index(line, ": ")
    key = substr(line, 1, colon_space-1)
    value = substr(line, colon_space+2)
    HTTP_REQUEST_HEADERS[key] = value
  }

  delete REQUEST_COOKIES
  delete RESPONSE_COOKIES
  split(HTTP_REQUEST_HEADERS["Cookie"], splitted, "; ")
  for(i in splitted) {
    idx = index(splitted[i], "=")
    key = substr(splitted[i], 1, idx-1)
    value = substr(splitted[i], idx+1)
    if (value ~ "^\".*\"$") {
      value = substr(value, 2, length(value) - 2)
    }
    REQUEST_COOKIES[key]["value"] = value
  }
  delete HTTP_REQUEST_PARAMETERS
  
  if (length(HTTP_REQUEST["parameters"]) > 0) {
    url::decodeWwwForm(HTTP_REQUEST["parameters"])
    for (i in url::params) {
      HTTP_REQUEST_PARAMETERS[i] = url::params[i]
    }
  }
}

function finishRequestFromRaw(raw_content) {
  printf "%s", raw_content |& INET;
  close(INET);
  REQUEST_PROCESS = 0;
  delete HTTP_RESPONSE_HEADERS
  next;
}

function finishRequest(status_num, content) {
  finishRequestFromRaw(buildHttpResponse(status_num, content))
}

function buildHttpResponse(status_num, content,    header_str, status) {
  
  switch(status_num) {
    case 200: status = "200 OK"; break;
    case 204: status = "204 OK"; break;
    case 302: status = "302 Found"; break;
    case 401: status = "401 Unauthorized"; break;
    case 404: status = "404 Not Found"; break;
    default:  status = "500 Not Handled";break;
  }

  for(i in HTTP_RESPONSE_HEADERS) {
    header_str = header_str i ": " HTTP_RESPONSE_HEADERS[i] "\n";
  }
  header_str = header_str buildCookieHeader();

  return sprintf("HTTP/1.1 %s\n%s\n%s", status, header_str, content);
}

function buildCookieHeader(        header_str, max_age, secure) {
  header_str = ""
  for (i in RESPONSE_COOKIES) {
    if ("Max-Age" in RESPONSE_COOKIES[i]) {
      max_age = sprintf("; Max-Age=%s;", RESPONSE_COOKIES[i]["Max-Age"])
    } else {
      max_age = ""
    }
    if (awk::AWKBLOG_HOSTNAME ~ /^https:\/\//) {
      secure = sprintf("; Secure")
    } else {
      secure = ""
    }
    header_str = sprintf("%sSet-Cookie: %s=%s; SameSite=Lax; HttpOnly%s%s\n", header_str, i, RESPONSE_COOKIES[i]["value"], max_age, secure)
  }
  return header_str
}

function log_request() {
  print "request: ";
  print "  method:";
  print "    " HTTP_REQUEST["method"];
  print "  path:";
  print "    " HTTP_REQUEST["path"];
  print "  parameter:";
  for (i in HTTP_REQUEST_PARAMETERS) {
    print "    " i ": " HTTP_REQUEST_PARAMETERS[i];
  }
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

function getCookie(key) {
  if (key in REQUEST_COOKIES) {
      return REQUEST_COOKIES[key]["value"]
  }
  return ""
}

function setCookie(key, value) {
  RESPONSE_COOKIES[key]["value"] = value
}

function setCookieMaxAge(key, max_age) {
  RESPONSE_COOKIES[key]["Max-Age"] = max_age
}

function initializeHttp() {
  INET = "/inet/tcp/" PORT "/0/0";
  FS=""
  REQUEST_PROCESS = 0;
}

function renderHtml(status_num, content) {
  HTTP_RESPONSE_HEADERS["Content-Type"] = "text/html; charset=UTF-8"
  return buildHttpResponse(status_num, content)
}

function sed(status_num, content) {
  finishRequestFromRaw(renderHtml(status_num, content))
}

function redirect302(url) {
  HTTP_RESPONSE_HEADERS["Location"] = url
  finishRequest(302, "");
}

function setHeader(key, value) {
  HTTP_RESPONSE_HEADERS[key] = value
}

function requestPath() {
  return HTTP_REQUEST["path"]
}
