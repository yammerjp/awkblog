@namespace "controller"

function login__get() {
  state = lib::uuid()
  url = "https://github.com/login/oauth/authorize/?client_id=" awk::AWKBLOG_OAUTH_CLIENT_KEY "&redirect_uri=" awk::AWKBLOG_HOSTNAME "/oauth-callback&state=" state
  http::COOKIES[state] = state
  http::redirect302(url)
}
