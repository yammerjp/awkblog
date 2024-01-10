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
  ret["coverimage"] = pgsql::fetchResult(0, "coverimage")
}
