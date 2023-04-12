@namespace "controller"

function authed__get(headers, body,        variables, username) {
  variables["username"] = auth::getUsername()
  return http::renderHtml(200, template::render("src/view/authed/get.html", variables))
}
