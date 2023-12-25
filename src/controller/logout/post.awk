@namespace "controller"

function logout__post() {
  auth::logout()
  http::sendRedirect("/")
}
