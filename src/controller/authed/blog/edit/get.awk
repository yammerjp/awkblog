@namespace "controller"

function authed__blog__edit__get(accountId, blog, variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = auth::getUsername()

  accountId = auth::getAccountId()
  model::getBlog(blog, accountId)
  if ("error" in blog) {
    http::sendRedirect("/authed/blog/new")
  }

  variables["title"] = blog["title"]
  variables["description"] = blog["description"]
  logger::debug("length(variables[\"description\"]): " length(variables["description"]))

  template::render("authed/blog/edit/get.html", variables)
}
