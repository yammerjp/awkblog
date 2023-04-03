@namespace "controller"

function authed__get(headers, body,        variables, username) {
  encrypted_username = http::get_cookie("username")
  username = lib::aes256_decrypt(encrypted_username)
  if (length(username) == 0) {
    return http::render_html(401, "")
  }
  variables["username"] = username
  return http::render_html(200, lib::render_template("src/view/authed/get.html", variables))
}
