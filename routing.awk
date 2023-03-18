http::IS("GET", "/") {
  controller::get()
}

http::IS("GET", "/test") {
  http::render_html(200, "Hello, test!");
}

http::IS("GET", "/login") {
  controller::login__get()
}

http::IS("GET", "/oauth-callback") {
  controller::oauth_callback__get()
}

http::IS("GET", "/authed") {
  controller::authed__get()
}

http::IS("GET", "/authed/posts/new") {
  controller::authed__posts__new__get()
}

http::IS("POST", "/authed/posts") {
  controller::authed__posts__get()
}

http::IS_ANY() {
  http::finish_request(404, "");
}
