@namespace "controller"

function logout__post() {
  http::guardCSRF()

  auth::logout()
  http::sendRedirect(awk::AWKBLOG_HOSTNAME "/static")
}
