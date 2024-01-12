@namespace "controller"

function _blogname__get(        splitted, params, query, rows, id, html, blog, posts, templateVars) {
  split(http::getPath(), splitted, "@")
  username = splitted[2]

  accountId = model::getAccountId(username)
  if (accountId == "") {
    notfound()
    return
  }
  model::getBlog(blog, accountId)
  model::getPosts(posts, accountId)

  templateVars["username"] = username
  templateVars["blog_title"] = blog["title"]
  templateVars["blog_description"] = blog["description"]

  for(i = 1; i <= length(posts); i++) {
    templateVars["posts"][i]["blogname"] = username
    templateVars["posts"][i]["id"] = posts[i]["id"]
    templateVars["posts"][i]["title"] = posts[i]["title"]
  }

  template::render("_blogname/get.html", templateVars);
}
