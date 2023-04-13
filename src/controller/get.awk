@namespace "controller"

function get() {
  http::send(200, template::render("src/view/get.html"));
}
