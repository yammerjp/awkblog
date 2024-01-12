@namespace "controller"

function authed__blog__edit__post(    result, variables, title, description, accountId, blog) {
  auth::redirectIfFailedToVerify()
  accountId = auth::getAccountId() + 0

  model::getBlog(blog, accountId)
  if (("error" in blog)) {
    http::send(400)
  }

  variables["account_name"] = auth::getUsername()
  logger::debug("'" http::HTTP_REQUEST["body"] "'", "debugaddbrank")

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = html::escape(result["title"])
  description = html::escape(result["description"])
  logger::debug("length(description): " length(description), "debugaddbrank")
  logger::debug("description: '" description "'", "debugaddbrank")

  model::updateBlog(title, description, accountId)

  http::sendRedirect("/authed/blog/edit")
}
