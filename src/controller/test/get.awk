@namespace "controller"

function test__get() {
  http::sendHtml(200, "Hello, test!")
}
