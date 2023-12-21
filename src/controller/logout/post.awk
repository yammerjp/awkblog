@namespace "controller"

function logout__post() {
  auth::logout()
  http::sendRedirect(awk::AWKBLOG_HOSTNAME)
}
