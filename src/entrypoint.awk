BEGIN {
  logger::setProcessIdentifier(http::getPort())
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
  router::register("POST", "/authed/posts/new", "controller::authed__posts__new__post")
  router::register("GET", "/authed/posts/edit", "controller::authed__posts__edit__get")
  router::register("POST", "/authed/posts/edit", "controller::authed__posts__edit__post")
  router::register("POST", "/authed/posts/delete", "controller::authed__posts__delete__post")
  router::register("GET", "/authed/posts", "controller::authed__posts__get")
  router::register("GET", "/authed/settings", "controller::authed__settings__get")
  router::register("POST", "/authed/settings", "controller::authed__settings__post")
  router::register("GET", "/authed/styles", "controller::authed__styles__get")
  router::register("POST", "/authed/styles", "controller::authed__styles__post")
  router::register("GET", "/api/v1/editor/posts", "controller::api__v1__editor__posts__get")
  router::register("POST", "/api/v1/editor/posts", "controller::api__v1__editor__posts__post")
  router::register("GET", "/api/v1/editor/posts/*", "controller::api__v1__editor__posts___id__get")
  router::register("GET", "/api/v1/editor", "controller::api__v1__editor__get")
  router::register("POST", "/api/v1/images/uploading-sign", "controller::api__v1__images__uploading_sign__post")
  router::register("GET", "/api/v1/accounts", "controller::api__v1__accounts__get")
  router::register("GET", "/.well-known/webfinger", "controller::well_known_webfinger_get")
  router::register("GET", "/*", "controller::_account_name__get")
  router::register("GET", "/*/rss.xml", "controller::_account_name__rss_xml__get")
  router::register("GET", "/*/style.css", "controller::_account_name__style_css__get")
  router::register("GET", "/*/actor.json", "controller::_account_name__actor_json__get")
  router::register("GET", "/*/posts/*", "controller::_account_name__posts___id__get")
  router::register_notfound("controller::notfound")

  router::debug_print()

  http::initialize();
}

{
  pgsql::renewConnection()
  http::receiveRequest()
  router::call(http::getMethod(), http::getPath())
}
