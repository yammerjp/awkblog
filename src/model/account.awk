@namespace "model"

function getAccountId(account_name     , params, query, rows) {
  params[1] = account_name
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
  ret["id"] = pgsql::fetchResult(0, "id")
  ret["name"] = pgsql::fetchResult(0, "name")
  return
}

function getAccounts(result    , i, query, rows) {
  query = "SELECT id, name FROM accounts"
  pgsql::exec(query)
  rows = pgsql::fetchRows()
  for(i = 1; i <= rows; i++) {
    result[i]["id"] = pgsql::fetchResult(i-1, "id")
    result[i]["name"] = pgsql::fetchResult(i-1, "name")
    # TODO: add description
  }
}
