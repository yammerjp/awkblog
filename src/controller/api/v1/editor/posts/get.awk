@load "json"
@namespace "controller"

function api__v1__editor__posts__get(    result) {
  if (!auth::verify()) {
    http::send(403)
    return
  }

  accountId = auth::getAccountId()



  model::getPosts(result, accountId)
  httpjson::render(result)
}
