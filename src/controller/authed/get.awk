@namespace "controller"

function authed__get() {
  http::render_html(200, lib::render_template("src/veiw/authed/get.html"));
}
