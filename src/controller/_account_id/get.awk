@namespace "controller"

function _account_id__get(        splitted, params, query, rows, id, html, result, template_vars) {
  split(http::request_path(), splitted, "@")
  params[1] = splitted[2]
  query = "SELECT id, name FROM accounts WHERE name = $1;"
  pgsql::exec(query, params)

  rows = pgsql::fetch_rows()
  if (rows == 0) {
    http::finish_request(404, "");
    return
  } else if (rows > 1) {
    http::finish_request(500, "");
    return
  }

  username = pgsql::fetch_result(0, "name")
  id = pgsql::fetch_result(0, "id")

  delete params
  params[1] = id
  query = "SELECT title, content, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
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
  template_vars["username"] = username
  http::finish_request_from_html(200, lib::render_template("src/view/_account_id/get.html", template_vars));
}
