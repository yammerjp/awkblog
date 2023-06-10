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
  MIDDLEWARE_AUTH["username"] = splitted[3]
  return length(MIDDLEWARE_AUTH["userid"]) > 0 && length(MIDDLEWARE_AUTH["username"]) > 0
}

function redirectIfFailedToVerify() {
  if (!verify()) {
    http::sendRedirect("/")
  }
}

function getUsername() {
  return MIDDLEWARE_AUTH["username"]
}

function getAccountId() {
  return MIDDLEWARE_AUTH["userid"]
}

function login(userid, username,        params) {
  query = "INSERT INTO accounts( id, name ) VALUES ($1, $2) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;"
  params[1] = userid
  params[2] = username
  pgsql::exec(query, params)
  query = "SELECT id, name FROM accounts WHERE id = $1 AND name = $2;"
  pgsql::exec(query, params)
  login_session_str = sprintf("AWKBLOG_LOGIN_SESSION %d %s", userid, username)
  encrypted = aes256::encrypt(login_session_str)
  http::setCookie("login_session", encrypted)
}

function logout() {
  http::setHeader("clear-site-data" , "\"cache\", \"cookies\", \"storage\", \"executionContexts\"")
  http::setCookie("login_session", "empty")
  http::setCookieMaxAge("login_session", 1)
}
