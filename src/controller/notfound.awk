@namespace "controller"

function notfound() {
  http::sendHtml(404, template::render("src/view/404.html"));
}
