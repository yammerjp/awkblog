@namespace "controller"

function authed__posts__edit__get(    postId, result, accountId, variables) {
  auth::redirectIfFailedToVerify()

  encrypted_username = http::getCookie("username")
  if (encrypted_username != "") {
      username = aes256::decrypt(encrypted_username)
  }

  postId = http::getParameter("post_id") + 0
  accountId = auth::getAccountId() + 0
  logger::debug("postId: " postId)
  logger::debug("accountId: " accountId)

  model::getPostWithAccountId(result, postId, accountId)
  if ("error" in result) {
    http::send(403)
    return
  }
  variables["post_id"] = result["id"]
  variables["title"] = result["title"]
  variables["content"] = result["content"]

  variables["username"] = username
  template::render("authed/posts/edit/get.html", variables)
}
