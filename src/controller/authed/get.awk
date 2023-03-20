@namespace "controller"

function authed__get() {
  http::finish_request_from_html(200, lib::render_template("src/veiw/authed/get.html"));
}
