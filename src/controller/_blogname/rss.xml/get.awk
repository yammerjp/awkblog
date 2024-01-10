@namespace "controller"

function _blogname__rss_xml__get(        path_parts, splitted, params, query, rows, id, html, result, templateVars) {
  split(http::getPath(), path_parts, "/")
  split(path_parts[2], splitted, "@")
  username = splitted[2]


  accountId = model::getAccountId(username)
  if (accountId == "") {
    notfound()
    return
  }

  templateVars["author_account_name"] = username
  templateVars["blog_title"] = "this is blog title" # TODO: get from database
  templateVars["blog_description"] = "this is blog description" # TODO: get from database
  templateVars["copyright"] = "Copyright 2024 " username

  templateVars["account_url"] = http::getHostName() "/@" username

  model::getPosts(result, accountId)

  for(i = 1; i <= length(result); i++) {
    templateVars["posts"][i]["id"] = result[i]["id"]
    templateVars["posts"][i]["title"] = result[i]["title"]
    templateVars["posts"][i]["content"] =  markdown::parseMultipleLines(result[i]["content"])
    templateVars["posts"][i]["created_at"] = result[i]["created_at"] # TODO: fix format
  }

  template::render("_blogname/rss.xml/get.xml", templateVars, 200, "xml");
}
