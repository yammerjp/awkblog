http::IS("GET", "/") {
  controller::get()
}

http::IS("GET", "/test") {
  http::finish_request_from_html(200, "Hello, test!");
}

http::IS("GET", "/login") {
  controller::login__get()
}

http::IS("GET", "/oauth-callback") {
  controller::oauth_callback__get()
}

http::IS("GET", "/authed") {
  http::finish_request_from_raw(controller::authed__get(HTTP_REQUEST_HEADERS, HTTP_REQUEST["body"]))
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
