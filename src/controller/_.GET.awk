@namespace "controller"

function _account_name__get(        splitted, params, query, rows, id, html, blog, posts, templateVars, description, accountName, accountId) {
  split(http::getPath(), splitted, "@")
  accountName = splitted[2]

  accountId = model::getAccountId(accountName)
  if (accountId == "") {
    notfound()
    return
  }
  model::getBlog(blog, accountId)
  model::getPosts(posts, accountId)

  templateVars["account_name"] = html::escape(accountName)
  templateVars["blog_title"] = html::escape(blog["title"])
  templateVars["blog_description"] = markdown::parseMultipleLines(html::escape(blog["description"]))
  templateVars["blog_author_profile"] = markdown::parseMultipleLines(html::escape(blog["author_profile"]))

  for(i = 1; i <= length(posts); i++) {
    templateVars["posts"][i]["id"] = html::escape(posts[i]["id"])
    templateVars["posts"][i]["title"] = html::escape(posts[i]["title"])
    templateVars["posts"][i]["description"] = text::headAbout500(html::toText(markdown::parseMultipleLines(html::escape(posts[i]["content"])))) "..."
  }

  template::render("_account_name/get.html", templateVars);
}
