@namespace "controller"

function authed__blog__get(accountId, blog, variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = auth::getUsername()

  accountId = auth::getAccountId()
  model::getBlog(blog, accountId)
  if ("error" in blog) {
    http::sendRedirect("/authed/blog/new")
  }
  template::render("authed/blog/get.html", variables)
}
