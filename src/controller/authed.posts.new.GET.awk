@namespace "controller"

function authed__posts__new__get(variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = html::escape(auth::getUsername())

  variables["title"] = "" # default title
  variables["content"] = "" # default content
  variables["og_image"] = "" # default og_image
  variables["s3_asset_host"] = html::escape(awss3::getAssetHost())

  template::render("authed/posts/new/get.html", variables)
}
