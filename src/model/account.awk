@namespace "model"

function getAccountId(username     , params, query, rows) {
  params[1] = username
  query = "SELECT id, name FROM accounts WHERE name = $1;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  if (rows == 0 || rows > 1) {
    return ""
  }

  return pgsql::fetchResult(0, "id")
}

function getAccount(ret, id    , params, query) {
  params[1] = id
  query = "SELECT id, name FROM accounts WHERE id = $1"
  pgsql::exec(query, params)
  rows = pgsql::fetchRows()
  if (rows != 1) {
    ret["error"] = "account not found"
    return
  }
  return
}
