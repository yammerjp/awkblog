function login_controller() {
  state = uuid()
  url = "https://github.com/login/oauth/authorize/?client_id=" AWKBLOG_OAUTH_CLIENT_KEY "&redirect_uri=" AWKBLOG_HOSTNAME "/oauth-callback&state=" state
  COOKIES[state] = state
  redirect302(url)
}
