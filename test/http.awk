@include "src/http.awk"
"build_http_response" {
  assertEqual("HTTP/1.1 200 OK\n\n", build_http_response(200, "ok"))
}
