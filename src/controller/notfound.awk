@namespace "controller"

function notfound() {
  http::sendHtml(404, compiled_templates::render("404.html"));
}
