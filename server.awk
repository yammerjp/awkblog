BEGIN {
  pgsql::createConnection()

  query = "SELECT count(id) as ids FROM posts;"
  pgsql::exec(query)
  rows = pgsql::fetchRows()
  print "Database Healthcheck: count(posts.id) (rows:" rows ") ... " pgsql::fetchResult(0, "ids")

  print "Start awkblog. listen port " PORT " ..."
  http::initializeHttp();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::receiveRequest();
}

http::IS("GET", "/") {
  controller::get()
}

http::IS("GET", "/test") {
  controller::test__get()
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

http::IS("GET", "/authed/posts") {
  controller::authed__posts__get()
}

http::IS("POST", "/authed/posts") {
  controller::authed__posts__post()
}

http::IS_STARTS_WITH("GET", "/@") {
  controller::_account_id__get()
}

http::IS_ANY() {
  controller::notfound()
}
