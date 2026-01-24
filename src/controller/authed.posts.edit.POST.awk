@namespace "controller"

function authed__posts__edit__post(        id, title, content, ogImage, account_id, query, params, result, accountId) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  id = result["post_id"] + 0
  title = result["title"]
  content = result["content"]
  ogImage = result["og_image"]
  accountId = auth::getAccountId()

  # Validate og_image URL - must be from S3_ASSET_HOST
  if (ogImage != "") {
    assetHost = awss3::getAssetHost()
    if (assetHost == "" || index(ogImage, assetHost) != 1) {
      ogImage = ""
    }
  }

  model::updatePost(title, content, ogImage, id, accountId)

  http::sendRedirect("/authed/posts")
}
