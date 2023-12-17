@load "json"
@namespace "controller"

function api__v1__editor__posts___id__get(    result, accountId, postId) {

  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()

  split(http::getPath(), splitted, "/")
  # ex) /api/v1/editor/posts/33
  postId = splitted[6]

  model::getPost(result, postId)

  if (result["account_id"] != accountId) {
    http::send(403)
  }

  httpjson::render(result)
}
