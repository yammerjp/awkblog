@namespace "auth"

function verify(        encrypted, decrypted) {
  encrypted = http::getCookie("login_session")
  if (encrypted == "empty" || encrypted == "") {
    logger::info("login_session is empty", "auth")
    return 0
  }
  decrypted = aes256::decrypt(encrypted)
  split(decrypted, splitted, " ")
  if (splitted[1] != "AWKBLOG_LOGIN_SESSION") {
    return 0
  }
  MIDDLEWARE_AUTH["userid"] = splitted[2]
  MIDDLEWARE_AUTH["account_name"] = splitted[3]
  return length(MIDDLEWARE_AUTH["userid"]) > 0 && length(MIDDLEWARE_AUTH["account_name"]) > 0
}

function redirectIfFailedToVerify() {
  if (!verify()) {
    http::sendRedirect("/")
  }
}

function redirectIfSuccessToVerify() {
  if (verify()) {
    http::sendRedirect("/authed")
  }
}

function forbiddenIfFailedToVerify() {
  if (!verify()) {
    http::send(403)
  }
}


function getUsername() {
  return MIDDLEWARE_AUTH["account_name"]
}

function getAccountId() {
  return MIDDLEWARE_AUTH["userid"]
}

function login(userid, account_name,        params, content) {
  query = "INSERT INTO accounts( id, name ) VALUES ($1, $2) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;"
  params[1] = userid
  params[2] = account_name
  pgsql::exec(query, params)

  delete params
  query = "INSERT INTO stylesheets (account_id, content) SELECT $1, $2 WHERE NOT EXISTS (SELECT account_id FROM stylesheets WHERE account_id = $3);"
  params[1] = userid
  params[2] = shell::exec("cat lib/default.css")
  params[3] = userid
  pgsql::exec(query, params)

  delete params
  params[1] = userid
  params[2] = account_name
  query = "SELECT id, name FROM accounts WHERE id = $1 AND name = $2;"
  pgsql::exec(query, params)
  login_session_str = sprintf("AWKBLOG_LOGIN_SESSION %d %s", userid, account_name)
  encrypted = aes256::encrypt(login_session_str)
  http::setCookie("login_session", encrypted)
}

function logout() {
  http::setCookie("login_session", "empty")
}
