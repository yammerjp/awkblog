BEGIN {
  pgsql::createConnection()

  query = "SELECT count(id) as ids FROM posts;"
  pgsql::exec(query)
  rows = pgsql::fetchRows()
  logger::info("Database Healthcheck: count(posts.id) (rows:" rows ") ... " pgsql::fetchResult(0, "ids"))

  router::register("GET", "/", "controller::get")
  router::register("GET", "/test", "controller::test__get")
  router::register("GET", "/login", "controller::login__get")
  router::register("POST", "/logout", "controller::logout__post")
  router::register("GET", "/oauth-callback", "controller::oauth_callback__get")
  router::register("GET", "/authed", "controller::authed__get")
  router::register("GET", "/authed/posts/new", "controller::authed__posts__new__get")
  router::register("GET", "/authed/posts", "controller::authed__posts__get")
  router::register("POST", "/authed/posts", "controller::authed__posts__post")
  router::register("GET", "/api/v1/editor/posts", "controller::api__v1__editor__posts__get")
  router::register("POST", "/api/v1/editor/posts", "controller::api__v1__editor__posts__post")
  router::register("GET", "/api/v1/editor/posts/*", "controller::api__v1__editor__posts___id__get")
  router::register("GET", "/api/v1/editor", "controller::api__v1__editor__get")
  router::register("GET", "/api/v1/accounts", "controller::api__v1__accounts__get")
  router::register("GET", "/*", "controller::_blogname__get")
  router::register("GET", "/*/posts/*", "controller::_blogname__posts___id__get")
  router::register("POST", "/private/shutdown", "controller::private__shutdown__post")
  router::register_notfound("controller::notfound")

  logger::info("Start awkblog. listen port " PORT " ...")
  http::initializeHttp();
}

{
  http::receiveRequest()
  router::call(http::getMethod(), http::getPath())
}
