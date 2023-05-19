@namespace "controller"

function authed__posts__get(    query, params, html, result, template_vars) {
  auth::redirectIfFailedToVerify()


  account_id = auth::getAccountId()

  query = "SELECT title, content, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
  params[1] = account_id
  pgsql::exec(query, params)

  html = ""

  rows = pgsql::fetchRows()
  for(i = 0; i < rows; i++) {
    result["title"] = pgsql::fetchResult(i, "title")
    result["content"] = pgsql::fetchResult(i, "content")
    result["created_at"] = pgsql::fetchResult(i, "created_at")
    html = html template::render("src/view/components/post.html", result)
  }

  template_vars["posts_html"] = html
  http::send(200, template::render("src/view/authed/posts/get.html", template_vars));
}
