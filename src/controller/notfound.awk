@namespace "controller"

function notfound() {
  http::finishRequest(404, "")
}
