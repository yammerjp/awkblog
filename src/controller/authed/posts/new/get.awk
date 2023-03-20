@namespace "controller"

function authed__posts__new__get() {
  encrypted_username = http::get_cookie("username")
  if (encrypted_username != "") {
      username = lib::aes256_decrypt(encrypted_username)
  }
  variables["username"] = username
  http::render_html(200, lib::render_template("src/view/authed/posts/new/get.html", variables))
}
