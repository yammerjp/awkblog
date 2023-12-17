@namespace "controller"

function authed__posts__get(    query, params, html, result, templateVars) {
  if (!auth::verify()) {
    http::sendRedirect(awk::AWKBLOG_HOSTNAME "/")
    return
  }

  accountId = auth::getAccountId()
  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    templateVars["posts"][i]["title"] = result[i]["title"]
    templateVars["posts"][i]["content"] = result[i]["content"]
    templateVars["posts"][i]["created_at"] = result[i]["created_at"]
  }

  http::sendHtml(200, template::render("src/view/authed/posts/get.html", templateVars));
}
