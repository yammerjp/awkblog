@namespace "controller"

function get() {
  http::sed(200, lib::renderTemplate("src/view/get.html"));
}
