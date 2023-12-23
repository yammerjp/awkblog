@namespace "controller"

function private__shutdown__post() {
  authHeader = http::getHeader("authorization")
  if (authHeader == "bearer " awk::PRIVATE_BEARER_TOKEN) {
    http::send(200, "success");
    exit 0
  } else {
    http::send(403, "Forbidden");
  }
}
