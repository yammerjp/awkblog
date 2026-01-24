@namespace "controller"

function authed__posts__new__post(        title, content, ogImage, accountId, query, params, result, account) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = result["title"]
  content = result["content"]
  ogImage = result["og_image"]
  accountId = auth::getAccountId()

  # Generate OGP image from title only if not provided
  if (ogImage == "") {
    model::getAccount(account, accountId)
    ogImage = ogp::generateAndUpload(title, account["name"], accountId)
  }

  model::createPost(title, content, ogImage, accountId)

  http::sendRedirect("/authed/posts")
}
