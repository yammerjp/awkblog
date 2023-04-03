@namespace "controller"

function authed__posts__post() {
  lib::decode_www_form(http::HTTP_REQUEST["body"])
  http::finish_request_from_html(200, lib::render_template("src/view/authed/posts/post.html", lib::KV));
}
