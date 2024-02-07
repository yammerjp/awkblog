@namespace "model"

function signin(accountId, accountName    , query, params) {
  query = "INSERT INTO accounts( id, name ) VALUES ($1, $2) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;"
  params[1] = accountId
  params[2] = accountName
  pgsql::exec(query, params)

  delete params
  query = "INSERT INTO stylesheets (account_id, content) SELECT $1, $2 WHERE NOT EXISTS (SELECT account_id FROM stylesheets WHERE account_id = $3);"
  params[1] = accountId
  params[2] = shell::exec("cat misc/default.css")
  params[3] = accountId
  pgsql::exec(query, params)

  delete params
  query = "INSERT INTO blogs (account_id, title, description, author_profile) SELECT $1, $2, $3, $4 WHERE NOT EXISTS (SELECT account_id FROM blogs WHERE account_id = $5);"
  params[1] = accountId
  params[2] = accountName "'s Blog"
  params[3] = ""
  params[4] = ""
  params[5] = accountId
  pgsql::exec(query, params)

  delete params
  params[1] = accountId
  params[2] = accountName
  query = "SELECT id, name FROM accounts WHERE id = $1 AND name = $2;"
  pgsql::exec(query, params)
  if (pgsql::fetchRows() != 1) {
    error::raise("failed to find account")
  }
}
