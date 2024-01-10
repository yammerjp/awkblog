@namespace "template"

function render(path, v, statusCode, contentType) {
  if (statusCode == "") {
    statusCode = 200
  }
  switch (contentType) {
    case "":
    case "html":
      http::setHeader("content-type", "text/html; charset=UTF-8")
      break
    case "xml":
      http::setHeader("content-type", "application/xml; charset=UTF-8")
      break
    default:
      error::raise("unknown content type", "middleware/template")
  }
  http::send(statusCode, compiled_templates::render("pages/" path, v));
}

