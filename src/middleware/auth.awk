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

function login(accountId, accountName    , loginSessionStr) {
  model::signin(accountId, accountName)
  loginSessionStr = sprintf("AWKBLOG_LOGIN_SESSION %d %s", accountId, accountName)
  http::setCookie("login_session", aes256::encrypt(loginSessionStr))
}

function logout() {
  http::setCookie("login_session", "empty")
}
