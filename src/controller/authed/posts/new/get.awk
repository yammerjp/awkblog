@namespace "controller"

function authed__posts__new__get() {
  auth::redirectIfFailedToVerify()

  encrypted_username = http::getCookie("username")
  if (encrypted_username != "") {
      username = aes256::decrypt(encrypted_username)
  }
  variables["username"] = username
  template::render("authed/posts/new/get.html", variables)
}
