@namespace "controller"

function authed__posts__post(        title, content, account_id, query, params) {
  http::guardCSRF()
  auth::redirectIfFailedToVerify()

  url::decodeWwwForm(http::HTTP_REQUEST["body"])
  title = html::escape(url::params["title"])
  content = html::escape(url::params["content"])
  account_id = auth::getAccountId()
  query = "INSERT INTO posts ( account_id, title, content ) VALUES ($1, $2, $3);"
  params[1] = account_id
  params[2] = title
  params[3] = content
  pgsql::exec(query, params)

  http::sendRedirect(AWKBLOG::HOST_NAME "/authed/posts")
}
