@include "src/lib/router.awk"
@include "testutil.awk"

"wildcard_compress" {
  replaced = router::wildcard_compress("/hello/world", 1)
  assertEqual("/*/world", replaced)

  replaced = router::wildcard_compress("/hello/world", 2)
  assertEqual("/hello/*", replaced)

  replaced = router::wildcard_compress("/@yammerjp", 1)
  assertEqual("/*", replaced)

}

"routing" {
  router::register("GET", "/", "controller::get")
  router::register("GET", "/test", "controller::test__get")
  router::register("GET", "/login", "controller::login__get")
  router::register("GET", "/oauth-callback", "controller::oauth_callback__get")
  router::register("GET", "/authed", "controller::authed__get")
  router::register("GET", "/authed/posts/new", "controller::authed__posts__new__get")
  router::register("GET", "/authed/posts", "controller::authed__posts__get")
  router::register("POST", "/authed/posts", "controller::authed__posts__post")
  router::register("GET", "/*", "controller::_account_id__get")
  router::register("GET", "/accounts/*/posts/*", "controller::_accounts__account_id__posts__post_id__get")
  router::register_notfound("controller::notfound")

  assertEqual("controller::authed__posts__post", router::find("POST", "/authed/posts"))
  assertEqual("controller::_account_id__get", router::find("GET", "/@yammerjp"))
  assertEqual("controller::notfound", router::find("POST", "/path/to/notfound"))
  assertEqual("controller::_accounts__account_id__posts__post_id__get", router::find("GET", "/accounts/13/posts/15"))
}
