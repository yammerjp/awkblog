@namespace "controller"

function _accountid__posts___id__get(        splitted, params, query, rows, id, html, result, templateVars) {
  split(http::getPath(), splitted, "/")
  at_username = splitted[2]
  post_id = splitted[4]
  # TODO: check to start from @
  username = substr(at_username, 2)

  accountId = model::getAccountId(username)
  if (accountId == "") {
    notfound()
    return
  }

  model::getPost(result, post_id)
  if ("error" in result) {
    notfound()
    return
  }
  templateVars["id"] = result["id"]
  templateVars["title"] = result["title"]
  templateVars["content"] = result["content"]
  templateVars["created_at"] = result["created_at"]

  http::sendHtml(200, template::render("src/view/:account_id/posts/_id/get.html", templateVars));
}
