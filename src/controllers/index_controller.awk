@namespace "controller"

function get() {
  http::render_html(200, lib::render_template("src/views/index.html"));
}
