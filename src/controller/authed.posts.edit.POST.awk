@namespace "controller"

function authed__posts__edit__post(        id, title, content, ogImage, account_id, query, params, result, accountId, account) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  id = result["post_id"] + 0
  title = result["title"]
  content = result["content"]
  ogImage = result["og_image"]
  accountId = auth::getAccountId()

  # Generate OGP image from title only if not provided
  if (ogImage == "") {
    model::getAccount(account, accountId)
    ogImage = ogp::generateAndUpload(title, account["name"], accountId)
  }

  model::updatePost(title, content, ogImage, id, accountId)

  http::sendRedirect("/authed/posts")
}
