BEGIN {
  pgsql::createConnection()

  query = "SELECT count(id) as ids FROM posts;"
  pgsql::exec(query)
  rows = pgsql::fetchRows()
  print "Database Healthcheck: count(posts.id) (rows:" rows ") ... " pgsql::fetchResult(0, "ids")

  router::register("GET", "/", "controller::get")
  router::register("GET", "/test", "controller::test__get")
  router::register("GET", "/login", "controller::login__get")
  router::register("GET", "/oauth-callback", "controller::oauth_callback__get")
  router::register("GET", "/authed", "controller::authed__get")
  router::register("GET", "/authed/posts/new", "controller::authed__posts__new__get")
  router::register("GET", "/authed/posts", "controller::authed__posts__get")
  router::register("POST", "/authed/posts", "controller::authed__posts__post")
  router::register("GET", "/*", "controller::_account_id__get")
  router::register_notfound("controller::notfound")

  print "Start awkblog. listen port " PORT " ..."
  http::initializeHttp();
  while(1) {
    http::receiveRequest()
    router::call(http::getMethod(), http::getPath())
  }
}
