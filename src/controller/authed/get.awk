@namespace "controller"

function authed__get(headers, body,        variables, username) {
  variables["username"] = auth::get_username()
  return http::render_html(200, lib::render_template("src/view/authed/get.html", variables))
}
