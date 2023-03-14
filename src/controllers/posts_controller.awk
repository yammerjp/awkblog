function authed_posts_new_controller() {
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

function authed_posts_controller() {
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
