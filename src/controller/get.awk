@namespace "controller"

function get() {
  http::sendHtml(200, template::render("src/view/get.html"));
}
