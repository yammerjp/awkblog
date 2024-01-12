@namespace "model"

function getBlog(ret, accountId     , params, query, rows) {
  params[1] = accountId 
  query = "SELECT title, description, coverimage FROM blogs WHERE account_id = $1;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  if (rows == 0 || rows > 1) {
    ret["error"] = "notfound"
    return
  }

  ret["title"] = pgsql::fetchResult(0, "title")
  ret["description"] = pgsql::fetchResult(0, "description")
  logger::debug("length(ret[\"description\"]): " length(ret["description"]), "nowdebug")
  ret["coverimage"] = pgsql::fetchResult(0, "coverimage")
}

function createBlog(title, description, accountId    , params, query) {
  params[1] = title
  params[2] = description
  params[3] = accountId
  query = "INSERT INTO blogs (title, description, account_id) VALUES ($1, $2, $3);"
  pgsql::exec(query, params)
}

function updateBlog(title, description, accountId    , params, query) {
  params[1] = title
  params[2] = description
  params[3] = accountId
  query = "UPDATE blogs SET title = $1, description = $2 WHERE account_id = $3;"
  pgsql::exec(query, params)
}
