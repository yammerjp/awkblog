@namespace "controller"

function oauth_callback__get() {
  error = http::getParameter("error")
  code = http::getParameter("code")
  if (code == "" || error != "") {
    http::sendHtml(500, "failed")
    return
  }
  stateOnQuery = http::getParameter("state")
  stateOnCookie = http::getCookie("state")
  if (stateOnQuery == "" || stateOnQuery != stateOnCookie) {
    http::sendHtml(400, "invalid state")
    return
  }
  ret = shell::exec("curl -X POST -H 'Accept: application/json' '" awk::GITHUB_LOGIN_SERVER "/login/oauth/access_token?client_id=" awk::OAUTH_CLIENT_ID "&client_secret=" awk::OAUTH_CLIENT_SECRET "&code=" code "'")
  access_token = json::extractString(ret, "access_token")
  if (access_token == "") {
    http::sendHtml(500, "access token is not found")
    return
  }
  ret = shell::exec("curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' " awk::GITHUB_API_SERVER "/user")
  username = json::extractString(ret, "login")
  id = json::extractNumber(ret, "id")
  auth::login(id, username)
  http::sendRedirect(AWKBLOG::HOST_NAME "/authed")
}
