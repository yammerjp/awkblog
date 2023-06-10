@namespace "http"

function receiveRequest(    line, splitted, contentLength, readcharlen, leftover, parameters, colonSpace, result) {
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

function initializeHttp() {
  INET = "/inet/tcp/" PORT "/0/0";
  FS=""
  isRequestRecieived = 0;
}

function buildResponse(statusNum, content,    headerStr, status) {
  switch(statusNum) {
    case 200: status = "200 OK"; break;
    case 204: status = "204 OK"; break;
    case 302: status = "302 Found"; break;
    case 401: status = "401 Unauthorized"; break;
    case 403: status = "403 Forbidden"; break;
    case 404: status = "404 Not Found"; break;
    default:  status = "500 Not Handled";break;
  }

  for(i in HTTP_RESPONSE_HEADERS) {
    headerStr = headerStr i ": " HTTP_RESPONSE_HEADERS[i] "\n";
  }
  headerStr = headerStr buildCookieHeader();

  return sprintf("HTTP/1.1 %s\n%s\n%s", status, headerStr, content);
}

function sendRaw(rawContent) {
  printf "%s", rawContent |& INET;
  close(INET);
  isRequestRecieived = 0;
}

function send(statusNum, content) {
  sendRaw(buildResponse(statusNum, content))
}

function sendHtml(statusNum, content) {
  setHeader("content-type", "text/html; charset=UTF-8")
  logger::info(statusNum " flyip" getHeader("fly-client-ip") "x44ip" getHeader("x-forwarded-for") " " getMethod() " " getPath() " rf:" getHeader("referer") " ua:" getHeader("user-agent") , "http")
  return sendRaw(buildResponse(statusNum, content))
}

function sendRedirect(url) {
  HTTP_RESPONSE_HEADERS["Location"] = url
  send(302, "")
}

function sendFile(filePath,     contents) {
  contents = getFile(filePath)
  if (!contents) {
    send(404, "")
    return
  }
  setHeader("Cache-Control", "no-cache")
  setHeader("Content-Type", guessContentType(filePath))
  send(200, contents)
}

function guessContentType(filePath) {
  switch(filePath) {
    case /\.html$/:
      return "text/html; charset=utf-8"
    case /\.css$/:
      return "text/css"
    case /\.js$/:
      return "application/javascript"
    case /\.jpg$/:
    case /\.jpeg$/:
      return "image/jpeg"
    case /\.png$/:
      return "image/png"
      break
    case /\.gif$/:
      return "image/gif"
    case /\.ico$/:
      return "image/x-icon"
    default:
      return "text/plain"
  }
}

function getFile(filePath,        contents) {
  contents = ""
  while (getline line < filePath > 0) {
    if (contents) {
      contents = contents ORS
    }
    contents = contents line
  }
  close(filePath)
  return contents
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

function guardCSRF() {
  if (isCrossSiteRequest()) {
    send(400)
    return
  }
}

function isCrossSiteRequest() {
  return getHeader("origin") != awk::AWKBLOG_HOSTNAME
}
