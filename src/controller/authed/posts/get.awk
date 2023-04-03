@namespace "controller"

function authed__posts__get() {
  http::finish_request_from_html(200, lib::render_template("src/view/authed/posts/get.html"));
}
