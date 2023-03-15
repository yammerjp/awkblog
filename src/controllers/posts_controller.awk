function authed_posts_new_controller() {
  encrypted_username = get_cookie("username")
  if (encrypted_username != "") {
      username = aes256_decrypt(encrypted_username)
  }
  variables["username"] = username
  render_html(200, render_template("src/views/authed/posts/new.html", variables))
}

function authed_posts_controller() {
  decode_www_form(HTTP_REQUEST["body"])
  render_html(200, render_template("src/views/authed/posts.html", KV));
}
