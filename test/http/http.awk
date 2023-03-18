@include "src/http/http.awk"
@include "testutil.awk"
"build_http_response" {
  assertEqual("HTTP/1.1 200 OK\n\nok", http::build_http_response(200, "ok"))
}
