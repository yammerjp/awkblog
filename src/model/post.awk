@namespace "model"

function getPosts(result, id       , params, query, html, rows, i) {
  params[1] = id
  query = "SELECT id, title, content, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  for(i = 1; i <= rows; i++) {
    result[i]["id"] = pgsql::fetchResult(i-1, "id")
    result[i]["title"] = pgsql::fetchResult(i-1, "title")
    result[i]["content"] = pgsql::fetchResult(i-1, "content")
    result[i]["created_at"] = pgsql::fetchResult(i-1, "created_at")
  }
}

function getPost(result, id    , params) {
  params[1] = id
  query = "SELECT id, title, content, account_id, created_at FROM posts WHERE id = $1"
  pgsql::exec(query, params)
  rows = pgsql::fetchRows()
  if (rows != 1) {
    result["error"] = "not 1 record"
    return
  }
  result["id"] = pgsql::fetchResult(0, "id")
  result["title"] = pgsql::fetchResult(0, "title")
  result["content"] = pgsql::fetchResult(0, "content")
  result["account_id"] = pgsql::fetchResult(0, "account_id")
  result["created_at"] = pgsql::fetchResult(0, "created_at")
}

function createPost(title, content, accountId      , params, query) {
  query = "INSERT INTO posts ( account_id, title, content ) VALUES ($1, $2, $3);"
  params[1] = accountId
  params[2] = title
  params[3] = content
  pgsql::exec(query, params)
}
