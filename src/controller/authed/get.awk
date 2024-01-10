@namespace "controller"

function authed__get(variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = auth::getUsername()
  template::render("authed/get.html", variables)
}
