@namespace "controller"

function get() {
  http::finish_request_from_html(200, lib::render_template("src/view/get.html"));
}
