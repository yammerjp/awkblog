@namespace "controller"

function _account_id__get(        splitted, params, query, rows, id, html, result, templateVars) {
  split(http::getPath(), splitted, "@")
  username = splitted[2]

  accountId = model::getAccountId(username)
  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    html = html template::render("src/view/components/post.html", result[i])
  }

  templateVars["posts_html"] = html
  templateVars["username"] = username
  http::sendHtml(200, template::render("src/view/_account_id/get.html", templateVars));
}
