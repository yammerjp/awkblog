@namespace "controller"

function authed__get(headers, body) {
  return http::render_html(200, lib::render_template("src/view/authed/get.html"))
}
