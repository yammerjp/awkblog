@include "src/decode-www-form.awk";

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/test" {
  log_request();
  finish_request(200, NULL, "Hello, test!");
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/authed" {
  log_request();
  delete HTTP_RESPONSE
  HTTP_RESPONSE["header"][1] = "Content-Type: text/html; charset=UTF-8"
  HTTP_RESPONSE["body"] = "\
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
</html>"
  finish_request(200, HTTP_RESPONSE["header"], HTTP_RESPONSE["body"]);
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "POST" && HTTP_REQUEST["path"] == "/authed/posts" {
  decode_www_form(HTTP_REQUEST["body"][1])
  HTTP_RESPONSE["header"][1] = "Content-Type: text/html; charset=UTF-8"
  HTTP_RESPONSE["body"] = "\
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
</html>"
  log_request();
  finish_request(200, HTTP_RESPONSE["header"], HTTP_RESPONSE["body"]);
}
