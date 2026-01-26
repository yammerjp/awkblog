@namespace "controller"

function authed__posts__new__post(        title, content, ogImage, accountId, query, params, result, account) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(result, http::HTTP_REQUEST["body"])

  title = result["title"]
  content = result["content"]
  ogImage = result["og_image"]
  accountId = auth::getAccountId()

  logger::info("[controller] title=" title " content_length=" length(content) " ogImage=" ogImage " accountId=" accountId)
  logger::info("[controller] awss3::isDisabled()=" awss3::isDisabled())

  # Generate OGP image from title only if not provided and S3 is enabled
  if (ogImage == "" && !awss3::isDisabled()) {
    logger::info("[controller] Starting OGP generation...")
    model::getAccount(account, accountId)
    logger::info("[controller] Account name: " account["name"])
    ogImage = ogp::generateAndUpload(title, account["name"], accountId)
    logger::info("[controller] OGP result: " ogImage)
  }

  logger::info("[controller] Creating post with ogImage=" ogImage)
  model::createPost(title, content, ogImage, accountId)
  logger::info("[controller] Post created successfully")

  http::sendRedirect("/authed/posts")
}
