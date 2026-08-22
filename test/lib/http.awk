@include "src/lib/http.awk"
@include "src/lib/environ.awk"
@include "test/testutil.awk"

"buildResponse" {
  assertEqual("HTTP/1.1 200 OK\n\nok", http::buildResponse(200, "ok"))
}

"isValidRequestLine: accepts all supported methods" {
  n = split("HEAD GET POST PUT DELETE OPTIONS PATCH", methods, " ")
  for (i = 1; i <= n; i++) {
    assertEqual(1, http::isValidRequestLine(methods[i] " /path HTTP/1.1"))
  }
}

"isValidRequestLine: accepts HTTP/1.0" {
  assertEqual(1, http::isValidRequestLine("GET / HTTP/1.0"))
}

"isValidRequestLine: accepts a line with a trailing CR (real socket input)" {
  assertEqual(1, http::isValidRequestLine("HEAD /@yammerjp HTTP/1.1\r"))
}

"isValidRequestLine: rejects an unsupported method" {
  assertEqual(0, http::isValidRequestLine("TRACE / HTTP/1.1"))
}

"isValidRequestLine: rejects a missing leading slash" {
  assertEqual(0, http::isValidRequestLine("GET path HTTP/1.1"))
}

"isValidRequestLine: rejects an unsupported HTTP version" {
  assertEqual(0, http::isValidRequestLine("GET / HTTP/2"))
}
