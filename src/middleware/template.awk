@namespace "template"

function render(path, v, statusCode) {
  http::setHeader("content-type", "text/html; charset=UTF-8")
  if (statusCode == "") {
    statusCode = 200
  }
  http::send(statusCode, compiled_templates::render("pages/" path, v));
}

