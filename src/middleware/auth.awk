@namespace "auth"

function verify(        encrypted_username, username) {
  encrypted_username = http::get_cookie("login_session")
  if (encrypted_username == "empty") {
    return 0
  }
  username = lib::aes256_decrypt(encrypted_username)
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

function login(username) {
  http::set_cookie("login_session", lib::aes256_encrypt(username))
}

function logout() {
  http::set_header("Clear-Site-Data" , "\"cache\", \"cookies\", \"storage\", \"executionContexts\"")
  http::set_cookie("login_session", "empty")
  http::set_cookie_max_age("login_session", 1)
}
