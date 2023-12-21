@namespace "controller"

function authed__get() {
  auth::redirectIfFailedToVerify()

  variables["username"] = auth::getUsername()
  template::sendHtml("authed/get.html", variables)
}
