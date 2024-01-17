@namespace "controller"

function authed__get(variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = html::escape(auth::getUsername())
  template::render("authed/get.html", variables)
}
