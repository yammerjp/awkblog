@namespace "controller"

function authed__settings__post(    accountId, blog, result, title, description, authorProfile) {
  auth::redirectIfFailedToVerify()
  accountId = auth::getAccountId() + 0

  model::getBlog(blog, accountId)

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = html::escape(result["title"])
  description = html::escape(result["description"])
  authorProfile = html::escape(result["author_profile"])

  model::updateBlog(title, description, authorProfile, accountId)

  http::sendRedirect("/authed/settings")
}
