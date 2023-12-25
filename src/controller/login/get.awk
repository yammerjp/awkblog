@namespace "controller"

function login__get() {
  state = uuid::gen()
  url = ENVIRON["GITHUB_LOGIN_SERVER"] "/login/oauth/authorize?client_id=" ENVIRON["OAUTH_CLIENT_ID"] "&redirect_uri=" ENVIRON["OAUTH_CALLBACK_URI"] "&state=" state
  http::setCookie("state", state)
  http::sendRedirect(url)
}
