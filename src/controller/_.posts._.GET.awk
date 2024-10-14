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

  templateVars["account_name"] = html::escape(account_name)
  model::getBlog(blog, accountId)
  templateVars["blog_title"] = html::escape(blog["title"])
  templateVars["blog_description"] = markdown::parseMultipleLines(html::escape(blog["description"]))
  templateVars["blog_author_profile"] = markdown::parseMultipleLines(html::escape(blog["author_profile"]))

  model::getPost(post, post_id)
  if ("error" in post) {
    notfound()
    return
  }
  templateVars["id"] = html::escape(post["id"])
  templateVars["title"] = html::escape(post["title"])
  templateVars["content"] = markdown::parseMultipleLines(html::escape(post["content"]))
  templateVars["created_at"] = html::escape(post["created_at"])

  template::render("_account_name/posts/_id/get.html", templateVars);
}
