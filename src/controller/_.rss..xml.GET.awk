@namespace "controller"

function _account_name__rss_xml__get(        path_parts, splitted, params, query, rows, id, html, result, templateVars, blog, accountName, accountId) {
  split(http::getPath(), path_parts, "/")
  split(path_parts[2], splitted, "@")
  accountName = splitted[2]


  accountId = model::getAccountId(accountName)
  if (accountId == "") {
    notfound()
    return
  }

  model::getBlog(blog, accountId)
  templateVars["author_account_name"] = html::escape(accountName)
  templateVars["blog_title"] = html::escape(blog["title"])
  templateVars["blog_description"] = html::escape(blog["description"])
  templateVars["copyright"] = html::escape("Copyright 2024 " accountName)

  templateVars["account_url"] = http::getHostName() "/@" accountName

  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    templateVars["posts"][i]["id"] = html::escape(result[i]["id"])
    templateVars["posts"][i]["title"] = html::escape(result[i]["title"])
    templateVars["posts"][i]["content"] =  html::escape(markdown::parseMultipleLines(result[i]["content"]))
    templateVars["posts"][i]["created_at"] = html::escape(result[i]["created_at"]) # TODO: fix format
  }

  template::render("_account_name/rss.xml/get.xml", templateVars, 200, "xml");
}
