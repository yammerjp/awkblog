@namespace "controller"

function static__get(        splitted, params, query, rows, id, html, result, template_vars) {
  split(http::getPath(), splitted, "/")
  filename = splitted[3]
  if (!match(filename, /^[a-zA-Z0-9.]+$/)) {
    send(403, "")
    return
  }
  http::sendFile("static/"  filename)
}
