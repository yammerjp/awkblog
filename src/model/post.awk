@namespace "model"

function getPosts(result, id       , params, query, html, rows, i) {
  params[1] = id
  query = "SELECT id, title, content, og_image, created_at FROM posts WHERE account_id = $1 ORDER BY created_at DESC;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  for(i = 1; i <= rows; i++) {
    result[i]["id"] = pgsql::fetchResult(i-1, "id")
    result[i]["title"] = pgsql::fetchResult(i-1, "title")
    result[i]["content"] = pgsql::fetchResult(i-1, "content")
    result[i]["og_image"] = pgsql::fetchResult(i-1, "og_image")
    result[i]["created_at"] = pgsql::fetchResult(i-1, "created_at")
  }
}

function getPostWithAccountId(result, id, accountId    , params, query, rows) {
  params[1] = id
  params[2] = accountId
  query = "SELECT id, title, content, og_image, created_at FROM posts WHERE id = $1 AND account_id = $2;"
  pgsql::exec(query, params)
  rows = pgsql::fetchRows()
  if (rows != 1) {
    result["error"] = "not 1 record"
    return
  }
  result["id"] = pgsql::fetchResult(0, "id")
  result["title"] = pgsql::fetchResult(0, "title")
  result["content"] = pgsql::fetchResult(0, "content")
  result["og_image"] = pgsql::fetchResult(0, "og_image")
  result["created_at"] = pgsql::fetchResult(0, "created_at")
}


function getPost(result, id    , params, query, rows) {
  params[1] = id
  query = "SELECT id, title, content, og_image, account_id, created_at FROM posts WHERE id = $1"
  pgsql::exec(query, params)
  rows = pgsql::fetchRows()
  if (rows != 1) {
    result["error"] = "not 1 record"
    return
  }
  result["id"] = pgsql::fetchResult(0, "id")
  result["title"] = pgsql::fetchResult(0, "title")
  result["content"] = pgsql::fetchResult(0, "content")
  result["og_image"] = pgsql::fetchResult(0, "og_image")
  result["account_id"] = pgsql::fetchResult(0, "account_id")
  result["created_at"] = pgsql::fetchResult(0, "created_at")
}

function createPost(title, content, ogImage, accountId      , params, query) {
  query = "INSERT INTO posts ( account_id, title, content, og_image ) VALUES ($1, $2, $3, $4);"
  params[1] = accountId
  params[2] = title
  params[3] = content
  params[4] = ogImage
  pgsql::exec(query, params)
}

function updatePost(title, content, ogImage, id, accountId      , params, query) {
  logger::info("updatePost(" title ", " content ", " ogImage ", " id ", " accountId)
  query = "UPDATE posts SET title = $1, content = $2, og_image = $3 WHERE id = $4 AND account_id = $5;"
  params[1] = title
  params[2] = content
  params[3] = ogImage
  params[4] = id
  params[5] = accountId
  pgsql::exec(query, params)
}

function deletePost(id, accountId    , params, query) {
  logger::info("deletePost(" id  ", " accountId ")")
  query = "DELETE FROM posts WHERE id = $1 AND account_id = $2;"
  params[1] = id
  params[2] = accountId
  pgsql::exec(query, params)
}
