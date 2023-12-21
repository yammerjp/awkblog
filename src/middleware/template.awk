@namespace "template"

function sendHtml(path, v) {
  http::sendHtml(200, compiled_templates::render(path, v));
}

