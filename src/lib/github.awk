@load "json"
@namespace "github"

BEGIN {
  GITHUB_LOGIN_SERVER = environ::getOrPanic("GITHUB_LOGIN_SERVER")
  OAUTH_CLIENT_ID = environ::getOrPanic("OAUTH_CLIENT_ID")
  OAUTH_CLIENT_SECRET = environ::getOrPanic("OAUTH_CLIENT_SECRET")
  OAUTH_CALLBACK_URI = environ::getOrPanic("OAUTH_CALLBACK_URI")
  GITHUB_LOGIN_SERVER = environ::getOrPanic("GITHUB_LOGIN_SERVER")
  GITHUB_API_SERVER = environ::getOrPanic("GITHUB_API_SERVER")
}

function redirectUrl(state) {
  return GITHUB_LOGIN_SERVER "/login/oauth/authorize?client_id=" OAUTH_CLIENT_ID "&redirect_uri=" OAUTH_CALLBACK_URI "&state=" state
}

function verify(ret, code    , response, res_json, access_token) {
  if (!(code ~ /^[a-zA-Z0-9_ -]+$/)) {
    error::raise("github::verify", "invalid code")
  }

  response = shell::exec("curl -X POST -H 'Accept: application/json' '" GITHUB_LOGIN_SERVER "/login/oauth/access_token?client_id=" OAUTH_CLIENT_ID "&client_secret=" OAUTH_CLIENT_SECRET "&code=" code "'")
  json::from_json(response, res_json)
  access_token = res_json["access_token"]
  if (access_token == "") {
    ret["error"] = "access token is not found"
    return
  }

  if (!(access_token ~ /^[a-zA-Z0-9_ -]+$/)) {
    error::raise("github::verify", "invalid access token")
  }

  response = shell::exec("curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' " GITHUB_API_SERVER "/user")
  json::from_json(response, res_json)
  ret["loginname"] = res_json["login"]
  ret["id"] = res_json["id"]
}
