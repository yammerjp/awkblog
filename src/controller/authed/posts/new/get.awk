@namespace "controller"

function authed__posts__new__get() {
  encrypted_username = http::getCookie("username")
  if (encrypted_username != "") {
      username = lib::aes256Decrypt(encrypted_username)
  }
  variables["username"] = username
  http::sed(200, lib::renderTemplate("src/view/authed/posts/new/get.html", variables))
}
