@namespace "controller"

function authed__blog__new__post(    result, variables, title, description, accountId, blog) {
  auth::redirectIfFailedToVerify()
  accountId = auth::getAccountId() + 0

  model::getBlog(blog, accountId)
  if (!("error" in blog)) {
    http::send(400)
  }

  variables["account_name"] = auth::getUsername()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = html::escape(result["title"])
  description = html::escape(result["description"])

  model::createBlog(title, description, accountId)

  http::sendRedirect("/authed/blog/edit")
}
