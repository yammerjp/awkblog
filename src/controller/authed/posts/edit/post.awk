@namespace "controller"

function authed__posts__edit__post(        id, title, content, account_id, query, params, result) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  id = html::escape(result["post_id"]) + 0
  title = html::escape(result["title"])
  content = html::escape(result["content"])
  accountId = auth::getAccountId()

  model::updatePost(title, content, id, accountId)

  http::sendRedirect("/authed/posts")
}
