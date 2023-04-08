@namespace "controller"

function authed__posts__get(    query, params, html, result, template_vars) {
  account_id = auth::get_account_id()

  query = "SELECT title, content, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
  params[1] = account_id
  pgsql::exec(query, params)

  html = ""

  rows = pgsql::fetch_rows()
  for(i = 0; i < rows; i++) {
    result["title"] = pgsql::fetch_result(i, "title")
    result["content"] = pgsql::fetch_result(i, "content")
    result["created_at"] = pgsql::fetch_result(i, "created_at")
    html = html lib::render_template("src/view/components/post.html", result)
  }

  template_vars["posts_html"] = html
  http::finish_request_from_html(200, lib::render_template("src/view/authed/posts/get.html", template_vars));
}
