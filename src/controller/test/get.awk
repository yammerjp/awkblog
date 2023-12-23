@namespace "controller"

function test__get() {
  http::send(200, "Hello, test!")
}
