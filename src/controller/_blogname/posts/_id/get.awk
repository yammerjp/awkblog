@namespace "controller"

function _blogname__posts___id__get(        splitted, params, query, rows, id, html, blog, post, templateVars) {
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

  template::render("_blogname/posts/_id/get.html", templateVars);
}
