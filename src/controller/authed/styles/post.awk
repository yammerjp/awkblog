@namespace "controller"

function authed__styles__post(    accountId, blog, result, title, description, authorProfile) {
  auth::redirectIfFailedToVerify()
  accountId = auth::getAccountId() + 0

  model::getBlog(blog, accountId)

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])
  model::updateStylesheet(result["style"], accountId)

  http::sendRedirect("/authed/styles")
}
