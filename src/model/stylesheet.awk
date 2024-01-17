@namespace "model"

function getStylesheet(accountId     , params, query, rows) {
  params[1] = accountId + 0
  query = "SELECT content FROM stylesheets WHERE account_id = $1;"
  pgsql::exec(query, params)

  rows = pgsql::fetchRows()
  if (rows == 0 || rows > 1) {
    return ""
  }

  return pgsql::fetchResult(0, "content")
}

function insertStylesheet(accountId    , params, query, rows, content) {
  content = ""
  while (("lib/default.css" | getline) > 0) {
    content = content $0 "\n"
  }
  params[1] = accountId
  params[2] = content
  query = "INSERT INTO stylesheets (account_id, content) VALUES($1, $2)"
  pgsql::exec(query, params)
}

function updateStylesheet(content, accountId    , params, query) {
  params[1] = content
  params[2] = accountId
  query = "UPDATE stylesheets SET content = $1 WHERE account_id = $2"
  pgsql::exec(query, params)
}
