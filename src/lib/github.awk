@load "json"
@namespace "github"

function redirectUrl() {
}

function verify(ret, code    , response, res_json) {
  response = shell::exec("curl -X POST -H 'Accept: application/json' '" awk::GITHUB_LOGIN_SERVER "/login/oauth/access_token?client_id=" awk::OAUTH_CLIENT_ID "&client_secret=" awk::OAUTH_CLIENT_SECRET "&code=" code "'")
  json::from_json(response, res_json)
  access_token = res_json["access_token"]
  if (access_token == "") {
    ret["error"] = "access token is not found"
    return
  }
  response = shell::exec("curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' " awk::GITHUB_API_SERVER "/user")
  json::from_json(response, res_json)
  ret["loginname"] = res_json["login"]
  ret["id"] = res_json["id"]
}
