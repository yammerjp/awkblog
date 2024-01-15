@namespace "controller"

function _account_name__get(        splitted, params, query, rows, id, html, blog, posts, templateVars, description) {
  split(http::getPath(), splitted, "@")
  account_name = splitted[2]

  accountId = model::getAccountId(account_name)
  if (accountId == "") {
    notfound()
    return
  }
  model::getBlog(blog, accountId)
  model::getPosts(posts, accountId)

  templateVars["account_name"] = account_name
  templateVars["blog_title"] = blog["title"]
  templateVars["blog_description"] = blog["description"]

  for(i = 1; i <= length(posts); i++) {
    templateVars["posts"][i]["id"] = posts[i]["id"]
    templateVars["posts"][i]["title"] = posts[i]["title"]
    templateVars["posts"][i]["description"] = text::headAbout500(html::toText(markdown::parseMultipleLines(posts[i]["content"]))) "..."
  }

  template::render("_account_name/get.html", templateVars);
}
