@load "json"
@namespace "controller"

function api__v1__accounts__get(    result) {
  model::getAccounts(result)
  if ("error" in result) {
    http::send(403)
  }
  httpjson::render(result)
}
