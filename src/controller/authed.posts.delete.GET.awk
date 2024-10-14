@namespace "controller"

function authed__posts__delete__post(        id, title, content, account_id, query, params, result) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  id = result["post_id"] + 0
  accountId = auth::getAccountId()

  model::deletePost(id, accountId)

  # TODO: flash message

  http::sendRedirect("/authed/posts")
}
