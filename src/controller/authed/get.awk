@namespace "controller"

function authed__get() {
  variables["username"] = auth::getUsername()
  http::send(200, template::render("src/view/authed/get.html", variables))
}
