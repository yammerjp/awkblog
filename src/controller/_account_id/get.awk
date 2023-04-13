@namespace "controller"

function _account_id__get(        splitted, params, query, rows, id, html, result, template_vars) {
  split(http::getPath(), splitted, "@")
  params[1] = splitted[2]
  query = "SELECT id, name FROM accounts WHERE name = $1;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  if (rows == 0) {
    http::finishRequest(404, "");
    return
  } else if (rows > 1) {
    http::finishRequest(500, "");
    return
  }

  username = pgsql::fetchResult(0, "name")
  id = pgsql::fetchResult(0, "id")

  delete params
  params[1] = id
  query = "SELECT title, content, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
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
  template_vars["username"] = username
  http::send(200, template::render("src/view/_account_id/get.html", template_vars));
}
