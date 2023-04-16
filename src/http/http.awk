@namespace "http"

function http::IS_STARTS_WITH(method, pathPrefix,        path) {
  if (!isRequestRecieived || getMethod() != method) {
    return 0
  }
  path = getPath()
  if (length(pathPrefix) > length(path)) {
    return 0
  }
  return substr(path, 1, length(pathPrefix)) == pathPrefix
}

function http::IS(method, path) {
  return isRequestRecieived && getMethod() == method && (getPath() == path || getPath() == path "/")
}

function http::IS_ANY() {
  return isRequestRecieived
}

function receiveRequest(    line, splitted, contentLength, readcharlen, leftover, parameters, colonSpace) {
  $0 = "";

  delete HTTP_REQUEST
  delete HTTP_REQUEST_PARAMETERS
  delete REQUEST_COOKIES
  delete RESPONSE_COOKIES
  delete HTTP_RESPONSE_HEADERS
  delete HTTP_REQUEST_HEADERS

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
  parameters = splitted[3];
  HTTP_REQUEST["version"] = splitted[4];

  if (length(parameters) > 0) {
    url::decodeWwwForm(parameters)
    for (i in url::params) {
      HTTP_REQUEST_PARAMETERS[i] = url::params[i]
    }
  }


  contentLength = 0

  # read HTTP header
  for(i = 1; INET |& getline line > 0; i++) {
    if (line == "" || line == "\r") {
      break;
    }
    gsub(/\r/, "" , line)
    colonSpace = index(line, ": ")
    key = tolower(substr(line, 1, colonSpace-1))
    value = substr(line, colonSpace+2)
    HTTP_REQUEST_HEADERS[key] = value

    if (key == "content-length") {
      contentLength = int(substr(line, 17))
    }
  }

  # read HTTP body
  HTTP_REQUEST["body"] = ""

  # The end of the body is not read;\if the entire body is tried to be read, the operation is stalled due to waiting for the next input after the last character.
  leftover = 1

  while(contentLength > leftover) {
    if (contentLength > 1000) {
      readcharlen = 1000
    } else {
      readcharlen = contentLength - leftover
    }
    awk::RS = sprintf(".{%d}", readcharlen)
    INET |& getline
    HTTP_REQUEST["body"] = HTTP_REQUEST["body"] awk::RT
    contentLength -= readcharlen
  }
  awk::RS="\n"
  parseRequest()
  logRequest()

  isRequestRecieived = 1;
}

function parseRequest() {
  split(getHeader("cookie"), splitted, "; ")
  for(i in splitted) {
    idx = index(splitted[i], "=")
    key = substr(splitted[i], 1, idx-1)
    value = substr(splitted[i], idx+1)
    if (value ~ "^\".*\"$") {
      value = substr(value, 2, length(value) - 2)
    }

    REQUEST_COOKIES[key]["value"] = value;
  }
}

function finishRequestFromRaw(rawContent) {
  printf "%s", rawContent |& INET;
  close(INET);
  isRequestRecieived = 0;
  next;
}

function finishRequest(statusNum, content) {
  finishRequestFromRaw(buildHttpResponse(statusNum, content))
}

function buildHttpResponse(statusNum, content,    headerStr, status) {
  
  switch(statusNum) {
    case 200: status = "200 OK"; break;
    case 204: status = "204 OK"; break;
    case 302: status = "302 Found"; break;
    case 401: status = "401 Unauthorized"; break;
    case 404: status = "404 Not Found"; break;
    default:  status = "500 Not Handled";break;
  }

  for(i in HTTP_RESPONSE_HEADERS) {
    headerStr = headerStr i ": " HTTP_RESPONSE_HEADERS[i] "\n";
  }
  headerStr = headerStr buildCookieHeader();

  return sprintf("HTTP/1.1 %s\n%s\n%s", status, headerStr, content);
}

function buildCookieHeader(        headerStr, maxAge, secure) {
  headerStr = ""
  for (i in RESPONSE_COOKIES) {
    if ("Max-Age" in RESPONSE_COOKIES[i]) {
      maxAge = sprintf("; Max-Age=%s;", RESPONSE_COOKIES[i]["Max-Age"])
    } else {
      maxAge = ""
    }
    if (awk::AWKBLOG_HOSTNAME ~ /^https:\/\//) {
      secure = sprintf("; Secure")
    } else {
      secure = ""
    }
    headerStr = sprintf("%sSet-Cookie: %s=%s; SameSite=Lax; HttpOnly%s%s\n", headerStr, i, RESPONSE_COOKIES[i]["value"], maxAge, secure)
  }
  return headerStr
}

function logRequest(        body, headers) {
  print "request: ";
  print "  method:";
  print "    " getMethod();
  print "  path:";
  print "    " getPath();
  print "  parameter:";
  for (i in HTTP_REQUEST_PARAMETERS) {
    print "    " i ": " HTTP_REQUEST_PARAMETERS[i];
  }
  print "  header:";
  for (i in HTTP_REQUEST_HEADERS) {
    print "    " i ": " HTTP_REQUEST_HEADERS[i]
  }
  body = getBody()
  if (body != "") {
    print "  body:";
    print "    " body
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

function setCookieMaxAge(key, maxAge) {
  RESPONSE_COOKIES[key]["Max-Age"] = maxAge
}

function initializeHttp() {
  INET = "/inet/tcp/" PORT "/0/0";
  FS=""
  isRequestRecieived = 0;
}

function renderHtml(statusNum, content) {
  setHeader("content-type", "text/html; charset=UTF-8")
  return buildHttpResponse(statusNum, content)
}

function send(statusNum, content) {
  finishRequestFromRaw(renderHtml(statusNum, content))
}

function redirect302(url) {
  HTTP_RESPONSE_HEADERS["Location"] = url
  finishRequest(302, "");
}

function setHeader(key, value) {
  HTTP_RESPONSE_HEADERS[key] = value
}

function getPath() {
  return HTTP_REQUEST["path"]
}

function getMethod() {
  return HTTP_REQUEST["method"]
}

function getBody() {
  return HTTP_REQUEST["body"]
}

function getHeader(key) {
  return HTTP_REQUEST_HEADERS[key]
}

function getParameter(key) {
  return HTTP_REQUEST_PARAMETERS[key]
}
