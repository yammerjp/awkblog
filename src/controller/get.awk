@namespace "controller"

function get() {
  http::sed(200, template::render("src/view/get.html"));
}
