@namespace "controller"

function authed__settings__get(accountId, blog, variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = auth::getUsername()

  accountId = auth::getAccountId()
  model::getBlog(blog, accountId)
  variables["title"] = blog["title"]
  variables["description"] = blog["description"]
  variables["author_profile"] = blog["author_profile"]

  template::render("authed/settings/get.html", variables)
}
