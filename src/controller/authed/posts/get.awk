@namespace "controller"

function authed__posts__get(    query, params, html, result, templateVars) {
  auth::redirectIfFailedToVerify()

  accountId = auth::getAccountId()
  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    html = html template::render("src/view/components/post.html", result[i])
  }

  templateVars["posts_html"] = html
  http::sendHtml(200, template::render("src/view/authed/posts/get.html", templateVars));
}
