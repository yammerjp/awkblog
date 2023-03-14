function oauth_callback_controller() {
  error = HTTP_REQUEST_PARAMETERS["error"]
  code = HTTP_REQUEST_PARAMETERS["code"]
  if (code == "" || error != "") {
    render_html(500, "failed")
  }
  # TODO verify state
  ret = command_exec("curl -X POST -H 'Accept: application/json' 'https://github.com/login/oauth/access_token?client_id=" AWKBLOG_OAUTH_CLIENT_KEY "&client_secret=" AWKBLOG_OAUTH_CLIENT_SECRET "&code=" code "'")
  access_token = json_extract(ret, "access_token")
  if (access_token == "") {
    render_html(500, "access token is not found")
  }
  ret = command_exec("curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/user")
  username = json_extract(ret, "login")

  COOKIES["username"] = "\"" aes256_encrypt(username) "\""
  redirect302("/authed")
}
