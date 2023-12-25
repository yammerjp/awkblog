@namespace "controller"

function authed__posts__post(        title, content, account_id, query, params, result) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = html::escape(result["title"])
  content = html::escape(result["content"])
  accountId = auth::getAccountId()

  model::createPost(title, content, accountId)

  http::sendRedirect("/authed/posts")
}
