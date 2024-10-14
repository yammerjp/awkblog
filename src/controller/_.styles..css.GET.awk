@namespace "controller"

function _account_name__style_css__get(        path_parts, splitted, params, query, rows, id, html, result, templateVars, accountName, accountId) {
  split(http::getPath(), path_parts, "/")
  split(path_parts[2], splitted, "@")
  accountName = splitted[2]


  accountId = model::getAccountId(accountName)
  if (accountId == "") {
    notfound()
    return
  }

  http::setHeader("content-type", "text/css")
  http::send(200, model::getStylesheet(accountId))
}
