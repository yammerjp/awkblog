@load "json"
@namespace "controller"

function _account_name__actor_json__get(    splitted, atAccountName, accountName, accountId) {
  split(http::getPath(), splitted, "/")
  atAccountName = splitted[2]
  if (substr(atAccountName, 1, 1) != "@") {
    notfound()
    return
  }
  accountName = substr(atAccountName, 2)

  accountId = model::getAccountId(accountName)
  if (accountId == "") {
    notfound()
    return
  }

  result["@context"][1] = "https://www.w3.org/ns/activitystreams"
  result["@context"][2] = "https://w3id.org/security/v1"
  result["id"] = sprintf("%s/@%s", http::getHostName(), accountName)
  result["type"] = "Person"
  result["preferredUsername"] = accountName
  result["inbox"] = sprintf("%s/@%s/inbox", http::getHostName(), accountName)
  result["publicKey"]["id"] = sprintf("%s/@%s#main-key", http::getHostName(), accountName)
  result["publicKey"]["owner"] = sprintf("%s/@%s", http::getHostName(), accountName)
  result["publicKey"]["publicKeyPem"] = environ::get("AWKBLOG_PUBLIC_KEY")

  # model::getAccount(result, accountId)
  # if (result["error"] != "" ) {
  #   http::send(403)
  # }
  httpjson::render(result)
}
