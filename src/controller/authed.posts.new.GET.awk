@namespace "controller"

function authed__posts__new__get() {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = html::escape(auth::getUsername())

  variables["title"] = "" # default title
  variables["content"] = "" # default content

  template::render("authed/posts/new/get.html", variables)
}
