@include "src/decode-www-form.awk";

function uuid(    ret) {
  cmd = "uuidgen"
  cmd | getline ret
  close(cmd)
  return ret
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/test" {
  finish_request(200, NULL, "Hello, test!");
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/authorize" {
  state = uuid()
  url = "https://github.com/login/oauth/authorize/?client_id=" AWKBLOG_OAUTH_CLIENT_KEY "&redirect_uri=" AWKBLOG_HOSTNAME "/oauth-callback&state=" state
  headers[1] = "Location: " url
  headers[2] = "Set-Cookie: state=" state ";"
  finish_request(302, headers, "");
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/authed" {
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
