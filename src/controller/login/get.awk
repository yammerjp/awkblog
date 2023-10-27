@namespace "controller"

function login__get() {
  state = uuid::gen()
  url = awk::GITHUB_LOGIN_SERVER "/login/oauth/authorize?client_id=" awk::OAUTH_CLIENT_ID "&redirect_uri=" awk::OAUTH_CALLBACK_URI "&state=" state
  http::setCookie("state", state)
  http::sendRedirect(url)
}
