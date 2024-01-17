@namespace "controller"

function authed__styles__get(accountId, blog, variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = auth::getUsername()

  accountId = auth::getAccountId()
  variables["style"] = html::escape(model::getStylesheet(accountId))

  template::render("authed/styles/get.html", variables)
}
