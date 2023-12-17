@load "json"
@namespace "controller"

function api__v1__editor__posts__post(    req) {
  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()

  json::from_json(http::HTTP_REQUEST["body"], req)

  title = html::escape(req["title"])
  content = html::escape(req["content"])

  if (title == "") {
    http::send(400)
    return
  }
  if (content == "") {
    http::send(400)
    return
  }

  model::createPost(title, content, accountId)
  http::send(201)
  return
}
