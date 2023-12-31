@namespace "controller"

function authed__posts__get(    query, params, html, result, templateVars) {
  auth::redirectIfFailedToVerify()

  accountId = auth::getAccountId()
  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    templateVars["posts"][i]["id"] = result[i]["id"]
    templateVars["posts"][i]["title"] = result[i]["title"]
    templateVars["posts"][i]["content"] = markdown::parseMultipleLines(result[i]["content"])
    templateVars["posts"][i]["created_at"] = result[i]["created_at"]
  }

  template::render("authed/posts/get.html", templateVars)
}
