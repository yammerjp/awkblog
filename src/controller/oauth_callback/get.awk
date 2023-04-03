@namespace "controller"

function oauth_callback__get() {
  error = http::HTTP_REQUEST_PARAMETERS["error"]
  code = http::HTTP_REQUEST_PARAMETERS["code"]
  if (code == "" || error != "") {
    http::finish_request_from_html(500, "failed")
  }
  # TODO verify state
  ret = lib::command_exec("curl -X POST -H 'Accept: application/json' 'https://github.com/login/oauth/access_token?client_id=" awk::AWKBLOG_OAUTH_CLIENT_KEY "&client_secret=" awk::AWKBLOG_OAUTH_CLIENT_SECRET "&code=" code "'")
  access_token = lib::json_extract(ret, "access_token")
  if (access_token == "") {
    http::finish_request_from_html(500, "access token is not found")
  }
  ret = lib::command_exec("curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/user")
  username = lib::json_extract(ret, "login")

  http::COOKIES["username"] = "\"" lib::aes256_encrypt(username) "\""
  http::redirect302("/authed")
}
