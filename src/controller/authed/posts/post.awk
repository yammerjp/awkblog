@namespace "controller"

function authed__posts__post(        title, content, account_id, query, params) {
  lib::decode_www_form(http::HTTP_REQUEST["body"])
  title = lib::html_escape(lib::KV["title"])
  content = lib::html_escape(lib::KV["content"])
  account_id = auth::get_account_id()
  query = "INSERT INTO posts ( account_id, title, content ) VALUES ($1, $2, $3);"
  params[1] = account_id
  params[2] = title
  params[3] = content
  pgsql::exec(query, params)

  http::redirect302(AWKBLOG::HOST_NAME "/authed/posts")
}
