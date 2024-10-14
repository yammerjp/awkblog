@namespace "controller"

function authed__settings__get(accountId, blog, variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = html::escape(auth::getUsername())

  accountId = auth::getAccountId()
  model::getBlog(blog, accountId)
  variables["title"] = html::escape(blog["title"])
  variables["description"] = html::escape(blog["description"])
  variables["author_profile"] = html::escape(blog["author_profile"])

  template::render("authed/settings/get.html", variables)
}
