@include "src/lib/http.awk"
@include "test.awk"
"build_http_response" {
  assertEqual("HTTP/1.1 200 OK\n\nok", build_http_response(200, "ok"))
}
