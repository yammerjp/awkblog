@namespace "http"

function receiveRequest() {
  delete HTTP_REQUEST
  delete HTTP_REQUEST_PARAMETERS
  delete REQUEST_COOKIES
  delete RESPONSE_COOKIES
  delete HTTP_RESPONSE_HEADERS
  delete HTTP_REQUEST_HEADERS
  HTTP_REQUEST["body"] = ""
  HTTP_REQUEST["id"] = $0
  $0 = "";

  readFirstLine()
  readHeader()
  readBody()

  parseCookie()
  logRequest()
}

function readFirstLine(    line, splitted, parameters, result) {
  # read first line
  awk::RS="\n"
  INET |& getline line;
  if (line !~ /^\(HEAD|GET|POST|PUT|DELETE|OPTIONS|PATCH\) \/.* HTTP\/1\.1$/) {
    send(400)
    return
  }
  split(line, splitted,"[ ?]");
  HTTP_REQUEST["method"] = splitted[1];
  HTTP_REQUEST["path"] = splitted[2];
  parameters = splitted[3];
  HTTP_REQUEST["version"] = splitted[4];

  if (length(parameters) > 0) {
    url::decodeWwwForm(result, parameters)
    for (i in result) {
      HTTP_REQUEST_PARAMETERS[i] = result[i]
    }
  }
}

function readHeader(    line, colonSpace) {
  for(i = 1; INET |& getline line > 0; i++) {
    if (line == "" || line == "\r") {
      break;
    }
    gsub(/\r/, "" , line)
    colonSpace = index(line, ": ")
    key = tolower(substr(line, 1, colonSpace-1))
    value = substr(line, colonSpace+2)
    HTTP_REQUEST_HEADERS[key] = value
  }
}

function readBody(    contentLength, unread, leftover, reading) {
  contentLength = getHeader("content-length")
  if (contentLength !~ /^[0-9]+$/) {
    send(411)
  }
  if (contentLength == 0) {
    # body is nothing
    return
  }

  # The end of the body is not read;\if the entire body is tried to be read, the operation is stalled due to waiting for the next input after the last character.
  leftover = getHeader("x-body-leftover") + 0
  if (leftover < 1) {
    setHeader("content-type", "text/plain")
    send(400, "the HTTP Header 'X-Body-Leftover' must be greater than 0")
  }
  unread = contentLength - leftover
  while(unread > 0) {
    if (unread > 1000) {
      reading = 1000
    } else {
      reading = unread
    }
    awk::RS = sprintf(".{%d}", reading)
    INET |& getline
    HTTP_REQUEST["body"] = HTTP_REQUEST["body"] awk::RT
    unread -= reading
  }
  awk::RS = "\n"
}

function parseCookie(    splitted, i, idx, key, value) {
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

function buildCookieHeader(        headerStr, maxAge, secure) {
  headerStr = ""
  for (i in RESPONSE_COOKIES) {
    if ("Max-Age" in RESPONSE_COOKIES[i]) {
      maxAge = sprintf("; Max-Age=%s;", RESPONSE_COOKIES[i]["Max-Age"])
    } else {
      maxAge = ""
    }
    if (getHostName() ~ /^https:\/\//) {
      secure = sprintf("; Secure")
    } else {
      secure = ""
    }
    headerStr = sprintf("%sSet-Cookie: %s=%s; SameSite=Lax; HttpOnly%s%s\n", headerStr, i, RESPONSE_COOKIES[i]["value"], maxAge, secure)
  }
  return headerStr
}

function logRequest(        params, headers) {
  if (getPath() == "/test") {
    logger::debug("request: /test", "http")
    return
  }
  for (i in HTTP_REQUEST_PARAMETERS) {
    params = params "\n    " i ": " HTTP_REQUEST_PARAMETERS[i]
  }
  for (i in HTTP_REQUEST_HEADERS) {
    headers = headers "\n    " i ": " HTTP_REQUEST_HEADERS[i]
  }

  logger::debug(sprintf("\
request:\n\
  method:\n     %s\n\
  path:\n    %s\n\
  parameter:%s\n\
  header:%s\n\
  body:\n    %s\n\
", getMethod(), getPath(), params, headers, getBody()), "http")
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

function initialize(    port) {
  error::registerErrorHandler("http::internalServerError")

  port = ENVIRON["AWKBLOG_PORT"]
  if (port == "") {
    port = ENVIRON["PORT"] 
  }
  if (port == "") {
    error::panic("Need PORT env")
  }
  INET = "/inet/tcp/" port "/0/0";
  FS=""
  RS = "\n"

  logger::info("Start awkblog. listen port " PORT " ...")
}

function internalServerError(message, kind) {
  if (kind == "") {
    kind = "http_internal_server_error"
    logger::error("internal server error has occured", "http_internal_server_error")
  }
  logger::error(message, kind)

  http::setHeader("content-type", "text/html; charset=UTF-8")
  http::send(500, "An error has occured. Please return to the <a href=\"javascript:history.back()\">previous page</a>.")
}

function buildResponse(statusNum, content,    headerStr, status) {
  switch(statusNum) {
    case 200: status = "200 OK"; break;
    case 201: status = "201 No Content"; break;
    case 204: status = "204 OK"; break;
    case 302: status = "302 Found"; break;
    case 400: status = "400 Bad Request"; break;
    case 401: status = "401 Unauthorized"; break;
    case 403: status = "403 Forbidden"; break;
    case 404: status = "404 Not Found"; break;
    case 411: status = "411 Length Required"; break;
    default:  status = "500 Not Handled";break;
  }

  for(i in HTTP_RESPONSE_HEADERS) {
    headerStr = headerStr i ": " HTTP_RESPONSE_HEADERS[i] "\n";
  }
  headerStr = headerStr buildCookieHeader();

  return sprintf("HTTP/1.1 %s\n%s\n%s", status, headerStr, content);
}

function send(statusNum, content) {
  setHeader("x-awkblog-version", awk::getAwkblogVersion())
  logger::info(statusNum " flyip:" getHeader("fly-client-ip") " x44ip:" getHeader("x-forwarded-for") " " getMethod() " " getPath() " rf:" getHeader("referer") " ua:" getHeader("user-agent") , "http")
  printf "%s", buildResponse(statusNum, content) |& INET;
  close(INET);

  RS = "\n"
  next
}

function sendRedirect(url) {
  HTTP_RESPONSE_HEADERS["Location"] = url
  send(302, "")
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

function getRequestId() {
  return HTTP_REQUEST["id"]
}

function guardCSRF() {
  if (isCrossSiteRequest()) {
    send(400)
    return
  }
}

function isCrossSiteRequest() {
  return getHeader("origin") != getHostName()
}

function getHostName() {
  return ENVIRON["AWKBLOG_HOSTNAME"]
}
