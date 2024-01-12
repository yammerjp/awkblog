@namespace "controller"

function _blogname__get(        splitted, params, query, rows, id, html, blog, posts, templateVars) {
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
    templateVars["posts"][i]["blogname"] = account_name
    templateVars["posts"][i]["id"] = posts[i]["id"]
    templateVars["posts"][i]["title"] = posts[i]["title"]
  }

  template::render("_blogname/get.html", templateVars);
}
