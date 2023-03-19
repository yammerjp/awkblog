@namespace "controller"

function authed__posts__get() {
  lib::decode_www_form(http::HTTP_REQUEST["body"])
  http::render_html(200, lib::render_template("src/view/authed/posts.html", lib::KV));
}
