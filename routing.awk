REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/test" {
  render_html(200, "Hello, test!");
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/login" {
  login_controller()
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] ~ "/oauth-callback" {
  oauth_callback_controller()
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/authed" {
  authed_controller()
}
REQUEST_PROCESS && HTTP_REQUEST["method"] == "GET" && HTTP_REQUEST["path"] == "/authed/posts/new" {
  authed_posts_new_controller()
}

REQUEST_PROCESS && HTTP_REQUEST["method"] == "POST" && HTTP_REQUEST["path"] == "/authed/posts" {
  authed_posts_controller()
}
