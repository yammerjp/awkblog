@namespace "controller"

function authed__posts__new__post(        title, content, ogImage, accountId, query, params, result) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

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

  model::createPost(title, content, ogImage, accountId)

  http::sendRedirect("/authed/posts")
}
