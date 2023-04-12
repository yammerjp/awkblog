@include "src/http/http.awk"
@include "testutil.awk"
"buildHttpResponse" {
  assertEqual("HTTP/1.1 200 OK\n\nok", http::buildHttpResponse(200, "ok"))
}
