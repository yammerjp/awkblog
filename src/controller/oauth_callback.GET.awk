@namespace "controller"

function oauth_callback__get(    code, error, stateOnQuery, stateOnCookie, ret) {
  code = http::getParameter("code")
  error = http::getParameter("error")
  if (code == "" || error != "") {
    http::send(400, "failed to login")
    print "faild to login. code:" code " error:" error
    return
  }
  stateOnQuery = http::getParameter("state")
  stateOnCookie = http::getCookie("state")
  if (stateOnQuery == "" || stateOnQuery != stateOnCookie) {
    http::send(400, "invalid state")
    return
  }

  delete ret
  github::verify(ret, code)

  if (ret["error"] != "") {
    http::send(400, ret["error"])
    return
  }

  auth::login(ret["id"], ret["loginname"])
  http::sendRedirect("/authed")
}
