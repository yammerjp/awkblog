@load "json"
@namespace "controller"

function api__v1__editor__posts__get(    result, accountId) {
  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()



  model::getPosts(result, accountId)
  httpjson::render(result)
}
