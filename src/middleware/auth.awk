@namespace "auth"

function verify(        encrypted, decrypted) {
  encrypted = http::get_cookie("login_session")
  if (encrypted == "empty" || encrypted == "") {
    print "empty"
    return 0
  }
  decrypted = lib::aes256_decrypt(encrypted)
  split(decrypted, splitted, " ")
  if (splitted[1] != "AWKBLOG_LOGIN_SESSION") {
    return 0
  }
  MIDDLEWARE_AUTH["userid"] = splitted[2]
  MIDDLEWARE_AUTH["username"] = splitted[3]
  return length(MIDDLEWARE_AUTH["userid"]) > 0 && length(MIDDLEWARE_AUTH["username"]) > 0
}

function redirect_if_failed_to_verify() {
  if (!verify()) {
    http::redirect302("/")
  }
}

function get_username() {
  return MIDDLEWARE_AUTH["username"]
}

function get_account_id() {
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
  encrypted = lib::aes256_encrypt(login_session_str)
  http::set_cookie("login_session", encrypted)
}

function logout() {
  http::set_header("Clear-Site-Data" , "\"cache\", \"cookies\", \"storage\", \"executionContexts\"")
  http::set_cookie("login_session", "empty")
  http::set_cookie_max_age("login_session", 1)
}
