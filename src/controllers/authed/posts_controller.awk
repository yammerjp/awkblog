@namespace "controller"

function authed__posts__new__get() {
  encrypted_username = http::get_cookie("username")
  if (encrypted_username != "") {
      username = lib::aes256_decrypt(encrypted_username)
  }
  variables["username"] = username
  http::render_html(200, lib::render_template("src/views/authed/posts/new.html", variables))
}

function authed__posts__get() {
  lib::decode_www_form(http::HTTP_REQUEST["body"])
  http::render_html(200, lib::render_template("src/views/authed/posts.html", lib::KV));
}
