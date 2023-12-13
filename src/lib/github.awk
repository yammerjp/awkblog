@load "json"
@namespace "github"

function redirectUrl() {
}

function verify(ret, code    , response, res_json, res_json2) {
  response = shell::exec("curl -X POST -H 'Accept: application/json' '" awk::GITHUB_LOGIN_SERVER "/login/oauth/access_token?client_id=" awk::OAUTH_CLIENT_ID "&client_secret=" awk::OAUTH_CLIENT_SECRET "&code=" code "'")
  json::from_json(response, res_json)
  access_token = res_json["access_token"]
  delete res_json
  if (access_token == "") {
    ret["error"] = "access token is not found"
    return
  }
  cmd = "curl -H 'Authorization: Bearer " access_token "' -H 'Accept: application/vnd.github+json' -H 'X-GitHub-Api-Version: 2022-11-28' " awk::GITHUB_API_SERVER "/user"
  logger::debug("cmd: " cmd)
  response2 = shell::exec(cmd)
  logger::debug("response2: " response2)
  json::from_json(response2, res_json2)
  logger::debug("print res_json2")
  for (key in res_json2) {
    logger::debug("res_json2[" key "]: " res_json2[key])
  }
  ret["loginname"] = res_json2["login"]
  ret["id"] = res_json2["id"]
}
