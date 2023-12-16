@load "json"
@namespace "controller"

function api__v1__editor__get(    result) {
  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()

  model::getAccount(result, accountId)
  if (result["error"] != "" ) {
    http::send(403)
  }
  httpjson::render(result)
}
