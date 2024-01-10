@namespace "controller"

function login__get() {
  state = uuid::gen()
  url = github::redirectUrl(state)
  http::setCookie("state", state)
  http::sendRedirect(url)
}
