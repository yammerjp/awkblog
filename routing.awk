http::IS("GET", "/") {
  controller::get()
}

http::IS("GET", "/test") {
  http::send(200, "Hello, test!");
}

http::IS("GET", "/login") {
  controller::login__get()
}

http::IS("GET", "/oauth-callback") {
  controller::oauth_callback__get()
}

http::IS("GET", "/authed") {
  auth::redirectIfFailedToVerify()
  http::finishRequestFromRaw(controller::authed__get(HTTP_REQUEST_HEADERS, http::getBody()))
}

http::IS("GET", "/authed/posts/new") {
  auth::redirectIfFailedToVerify()
  controller::authed__posts__new__get()
}

http::IS("GET", "/authed/posts") {
  auth::redirectIfFailedToVerify()
  controller::authed__posts__get()
}

http::IS("POST", "/authed/posts") {
  auth::redirectIfFailedToVerify()
  controller::authed__posts__post()
}

http::IS_STARTS_WITH("GET", "/@") {
  controller::_account_id__get()
}

http::IS_ANY() {
  http::finishRequest(404, "");
}
