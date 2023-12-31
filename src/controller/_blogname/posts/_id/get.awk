@namespace "controller"

function _blogname__posts___id__get(        splitted, params, query, rows, id, html, result, templateVars) {
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
  templateVars["content"] = markdown::parseMultipleLines(result["content"])
  templateVars["created_at"] = result["created_at"]

  template::render("_blogname/posts/_id/get.html", templateVars);
}
