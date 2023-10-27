@namespace "github"

function redirectUrl() {
}

function verify(ret, code) {
  json = shell::exec("curl -X POST -H 'Accept: application/json' '" awk::GITHUB_LOGIN_SERVER "/login/oauth/access_token?client_id=" awk::OAUTH_CLIENT_ID "&client_secret=" awk::OAUTH_CLIENT_SECRET "&code=" code "'")
  access_token = json::extractString(json, "access_token")
  if (access_token == "") {
    ret["error"] = "access token is not found"
    return
  }
  json = shell::exec("curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' " awk::GITHUB_API_SERVER "/user")
  ret["loginname"] = json::extractString(json, "login")
  ret["id"] = json::extractNumber(json, "id")
}
