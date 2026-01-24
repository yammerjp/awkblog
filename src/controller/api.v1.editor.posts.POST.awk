@load "json"
@namespace "controller"

function api__v1__editor__posts__post(    req, accountId, title, content, ogImage, account) {
  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()

  json::from_json(http::HTTP_REQUEST["body"], req)

  title = req["title"]
  content = req["content"]

  if (title == "") {
    http::send(400)
    return
  }
  if (content == "") {
    http::send(400)
    return
  }

  ogImage = req["ogImage"]

  # Generate OGP image from title only if not provided
  if (ogImage == "") {
    model::getAccount(account, accountId)
    ogImage = ogp::generateAndUpload(title, account["name"], accountId)
  }

  model::createPost(title, content, ogImage, accountId)
  http::send(201)
  return
}
