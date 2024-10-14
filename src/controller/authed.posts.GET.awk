@namespace "controller"

function authed__posts__get(    query, params, html, result, templateVars) {
  auth::redirectIfFailedToVerify()

  templateVars["account_name"] = html::escape(auth::getUsername())

  accountId = auth::getAccountId()
  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    templateVars["posts"][i]["id"] = html::escape(result[i]["id"])
    templateVars["posts"][i]["title"] = html::escape(result[i]["title"])
    templateVars["posts"][i]["content"] = markdown::parseMultipleLines(html::escape(result[i]["content"]))
    templateVars["posts"][i]["created_at"] = html::escape(result[i]["created_at"])
  }

  template::render("authed/posts/get.html", templateVars)
}
