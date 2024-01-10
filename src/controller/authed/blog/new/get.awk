@namespace "controller"

function authed__blog__new__get(accountId, blog) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = auth::getUsername()

  accountId = auth::getAccountId()

  model::getBlog(blog, accountId)
  if (!("error" in blog)) {
    http::sendRedirect("/authed/blog")
  }

  template::render("authed/blog/new/get.html", variables)
}
