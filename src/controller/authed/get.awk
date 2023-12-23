@namespace "controller"

function authed__get() {
  auth::redirectIfFailedToVerify()

  variables["username"] = auth::getUsername()
  template::render("authed/get.html", variables)
}
