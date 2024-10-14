@namespace "controller"

function authed__settings__post(    accountId, blog, result, title, description, authorProfile) {
  auth::redirectIfFailedToVerify()
  accountId = auth::getAccountId() + 0

  model::getBlog(blog, accountId)

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = result["title"]
  description = result["description"]
  authorProfile = result["author_profile"]

  model::updateBlog(title, description, authorProfile, accountId)

  http::sendRedirect("/authed/settings")
}
