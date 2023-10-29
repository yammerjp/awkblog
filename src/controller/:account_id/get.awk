@namespace "controller"

function _account_id__get(        splitted, params, query, rows, id, html, result, templateVars) {
  split(http::getPath(), splitted, "@")
  username = splitted[2]

  accountId = model::getAccountId(username)
  if (accountId == "") {
    notfound()
    return
  }
  model::getPosts(result, accountId)

  templateVars["username"] = username
  for(i = 1; i <= length(result); i++) {
    templateVars["posts"][i]["blogname"] = username
    templateVars["posts"][i]["id"] = result[i]["id"]
    templateVars["posts"][i]["title"] = result[i]["title"]
  }

  http::sendHtml(200, template::render("src/view/:account_id/get.html", templateVars));
}
