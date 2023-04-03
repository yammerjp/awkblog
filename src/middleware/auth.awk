@namespace "auth"

function verify(        encrypted, decrypted, userid, username) {
  encrypted = http::get_cookie("login_session")
  if (encrypted == "empty") {
    return 0
  }
  decrypted = lib::aes256_decrypt(encrypted)
  split(decrypted, splitted, " ")
  userid = splitted[1]
  username = splitted[2]
  MIDDLEWARE_AUTH["userid"] = userid
  MIDDLEWARE_AUTH["username"] = username
  return length(username) > 0
}

function redirect_if_failed_to_verify() {
  if (!verify()) {
    http::redirect302("/")
  }
}

function get_username() {
  return MIDDLEWARE_AUTH["username"]
}

function userid() {
  return MIDDLEWARE_AUTH["userid"]
}

function login(userid, username,        params) {
  delete params;
  params[1] = userid
  params[2] = username
  pgsql::exec("SELECT id, name FROM accounts WHERE id =  $1 AND accounts =  $2;",  params)
#  ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name ;
  print "id: " pgsql::fetch_result(0, "id")
  login_session_str = sprintf("%s %s", userid, username)
  encrypted = lib::aes256_encrypt(login_session_str)
  http::set_cookie("login_session", encrypted)
}

function logout() {
  http::set_header("Clear-Site-Data" , "\"cache\", \"cookies\", \"storage\", \"executionContexts\"")
  http::set_cookie("login_session", "empty")
  http::set_cookie_max_age("login_session", 1)
}
