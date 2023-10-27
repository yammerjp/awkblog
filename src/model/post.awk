@namespace "model"

function getPosts(result, id       , params, query, html, rows, i) {
  params[1] = id
  query = "SELECT title, content, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  for(i = 1; i <= rows; i++) {
    result[i]["title"] = pgsql::fetchResult(i-1, "title")
    result[i]["content"] = pgsql::fetchResult(i-1, "content")
    result[i]["created_at"] = pgsql::fetchResult(i-1, "created_at")
  }
}

function createPost(title, content, accountId      , params, query) {
  query = "INSERT INTO posts ( account_id, title, content ) VALUES ($1, $2, $3);"
  params[1] = accountId
  params[2] = title
  params[3] = content
  pgsql::exec(query, params)
}
