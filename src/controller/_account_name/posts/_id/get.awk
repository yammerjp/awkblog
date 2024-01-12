@namespace "controller"

function _account_name__posts___id__get(        splitted, params, query, rows, id, html, blog, post, templateVars) {
  split(http::getPath(), splitted, "/")
  at_account_name = splitted[2]
  post_id = splitted[4]
  # TODO: check to start from @
  account_name = substr(at_account_name, 2)

  accountId = model::getAccountId(account_name)
  if (accountId == "") {
    notfound()
    return
  }

  model::getBlog(blog, accountId)
  templateVars["blog_title"] = blog["title"]
  templateVars["blog_description"] = blog["description"]

  model::getPost(post, post_id)
  if ("error" in post) {
    notfound()
    return
  }
  templateVars["id"] = post["id"]
  templateVars["title"] = post["title"]
  templateVars["content"] = markdown::parseMultipleLines(post["content"])
  templateVars["created_at"] = post["created_at"]

  template::render("_account_name/posts/_id/get.html", templateVars);
}
