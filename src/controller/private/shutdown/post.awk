@namespace "controller"

BEGIN {
  PRIVATE_BEARER_TOKEN = environ::getOrPanic("PRIVATE_BEARER_TOKEN")
}

function private__shutdown__post() {
  authHeader = http::getHeader("authorization")
  if (authHeader == "bearer " PRIVATE_BEARER_TOKEN) {
    http::send(200, "success");
    exit 0
  } else {
    http::send(403, "Forbidden");
  }
}
