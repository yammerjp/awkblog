@namespace "model"

function getBlog(ret, accountId     , params, query, rows) {
  params[1] = accountId 
  query = "SELECT title, description, author_profile, coverimage FROM blogs WHERE account_id = $1;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  if (rows == 0 || rows > 1) {
    error::raise("blog record is not found, or found multiple record")
    return
  }

  ret["title"] = pgsql::fetchResult(0, "title")
  ret["description"] = pgsql::fetchResult(0, "description")
  ret["author_profile"] = pgsql::fetchResult(0, "author_profile")
  logger::debug(ret["author_profile"], "authorprofile")
  ret["coverimage"] = pgsql::fetchResult(0, "coverimage")
}

function updateBlog(title, description, authorProfile, accountId    , params, query) {
  params[1] = title
  params[2] = description
  params[3] = authorProfile
  params[4] = accountId
  query = "UPDATE blogs SET title = $1, description = $2, author_profile = $3 WHERE account_id = $4;"
  pgsql::exec(query, params)
}
