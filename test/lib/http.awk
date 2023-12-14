@include "src/lib/http.awk"
@include "test/testutil.awk"
"buildResponse" {
  assertEqual("HTTP/1.1 200 OK\n\nok", http::buildResponse(200, "ok"))
}
