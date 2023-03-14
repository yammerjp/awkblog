REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/test" {
  render_html(200, "Hello, test!");
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/login" {
  state = uuid()
  url = "https://github.com/login/oauth/authorize/?client_id=" AWKBLOG_OAUTH_CLIENT_KEY "&redirect_uri=" AWKBLOG_HOSTNAME "/oauth-callback&state=" state
  COOKIES[state] = state
  redirect302(url)
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] ~ /^\/oauth-callback?/ {
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
  render_html(200, "ok")
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/authed" {
  encrypted_username = get_cookie("username")
  if (encrypted_username != "") {
      username = aes256_decrypt(encrypted_username)
  }
  render_html(200, "\
<html>\
  <head>\
    <style>\
      html {\
        max-width: 70ch;\
        padding: 3em 1em;\
        margin: auto;\
        line-height: 1.75;\
        font-size: 1.25em;\
      }\
      h1,h2,h3,h4,h5,h6 {\
        margin: 3em 0 1em;\
      }\
      p,ul,ol {\
        margin-bottom: 2em;\
        color: #1d1d1d;\
        font-family: sans-serif;\
      }\
    </style>\
  </head>\
  <body>\
    <h1>hello, awkblog!</h1>\
    <div>username: " username "</div>\
    <form action=\"/authed/posts\" method=\"post\">\
      <div><label>title:<br><input type=\"text\" name=\"title\"></label></div>\
      <div><label>content:<br><textarea name=\"content\"></textarea></label></div>\
      <input type=\"hidden\" name=\"padding\" value=\"0\">\
      <div><input type=\"submit\" value=\"投稿する\"></div>\
    </form>\
  </body>\
</html>");
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "POST" && HTTP_REQUEST["path"] == "/authed/posts" {
  decode_www_form(HTTP_REQUEST["body"])
  render_html(200, "\
<html>\
  <head>\
    <style>\
      html {\
        max-width: 70ch;\
        padding: 3em 1em;\
        margin: auto;\
        line-height: 1.75;\
        font-size: 1.25em;\
      }\
      h1,h2,h3,h4,h5,h6 {\
        margin: 3em 0 1em;\
      }\
      p,ul,ol {\
        margin-bottom: 2em;\
        color: #1d1d1d;\
        font-family: sans-serif;\
      }\
    </style>\
  </head>\
  <body>\
    <h1>" KV["title"] "</h1>\
    <p>" KV["content"] "</p>\
  </body>\
</html>");
}
