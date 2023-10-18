@namespace "controller"

function login__get() {
  state = uuid::gen()
  url = "https://github.com/login/oauth/authorize/?client_id=" awk::OAUTH_CLIENT_ID "&redirect_uri=" awk::AWKBLOG_HOSTNAME "/oauth-callback&state=" state
  http::setCookie("state", state)
  http::sendRedirect(url)
}
