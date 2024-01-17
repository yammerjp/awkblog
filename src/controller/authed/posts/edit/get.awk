@namespace "controller"

function authed__posts__edit__get(    postId, result, accountId, variables) {
  auth::redirectIfFailedToVerify()

  variables["account_name"] = html::escape(auth::getUsername())

  postId = http::getParameter("post_id") + 0
  accountId = auth::getAccountId() + 0

  model::getPostWithAccountId(result, postId, accountId)
  if ("error" in result) {
    http::send(403)
    return
  }
  variables["post_id"] = html::escape(result["id"])
  variables["title"] = html::escape(result["title"])
  variables["content"] = html::escape(result["content"])

  template::render("authed/posts/edit/get.html", variables)
}
