@namespace "controller"

function get() {
  auth::redirectIfSuccessToVerify()

  template::render("get.html")
}
