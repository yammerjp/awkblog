@namespace "controller"

function authed__get() {
  if (!auth::verify()) {
    http::sendRedirect(awk::AWKBLOG_HOSTNAME "/")
    return
  }

  variables["username"] = auth::getUsername()
  http::sendHtml(200, template::render("src/view/authed/get.html", variables))
}
