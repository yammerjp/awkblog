@namespace "compiled_templates"

function render(path, v) {
  gsub("/", "SLASH", path)
  gsub("\\.", "DOT", path)
  gsub("\n", "", path)
  funcname = "compiled_templates::render_" path
  logger::debug("path : " path)
  logger::debug("funcname : " funcname)
  return @funcname(v)
}
function render__blognameSLASHpostsSLASH_idSLASHgetDOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <head>\n    <style>\n      html {\n        max-width: 70ch;\n        padding: 3em 1em;\n        margin: auto;\n        line-height: 1.75;\n        font-size: 1.25em;\n      }\n      h1,h2,h3,h4,h5,h6 {\n        margin: 3em 0 1em;\n      }\n      p,ul,ol {\n        margin-bottom: 2em;\n        color: #1d1d1d;\n        font-family: sans-serif;\n      }\n    </style>\n  </head>\n  <body>\n    <h1>");
  ret = ret sprintf("%s",  v["title"]);
  ret = ret sprintf("%s", "</h1>\n    <div>posted: ");
  ret = ret sprintf("%s",  v["created_at"]);
  ret = ret sprintf("%s", "</div>\n    <main>\n      ");
  ret = ret sprintf("%s",  v["content"]);
  ret = ret sprintf("%s", "\n    </main>\n  </body>\n</html>\n");
  return ret
}
function render__blognameSLASHgetDOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <head>\n    <style>\n      html {\n        max-width: 70ch;\n        padding: 3em 1em;\n        margin: auto;\n        line-height: 1.75;\n        font-size: 1.25em;\n      }\n      h1,h2,h3,h4,h5,h6 {\n        margin: 3em 0 1em;\n      }\n      p,ul,ol {\n        margin-bottom: 2em;\n        color: #1d1d1d;\n        font-family: sans-serif;\n      }\n    </style>\n  </head>\n  <body>\n    <h1>posts of ");
  ret = ret sprintf("%s",  v["username"]);
  ret = ret sprintf("%s", "</h1>\n      ");
 for(i in v["posts"]) { 
  ret = ret sprintf("%s", "\n        <div>\n          <a href=\"/@");
  ret = ret sprintf("%s",  v["posts"][i]["blogname"]);
  ret = ret sprintf("%s", "/posts/");
  ret = ret sprintf("%s",  v["posts"][i]["id"]);
  ret = ret sprintf("%s", "\">");
  ret = ret sprintf("%s",  v["posts"][i]["title"]);
  ret = ret sprintf("%s", "</a>\n        </div>\n      ");
 } 
  ret = ret sprintf("%s", "\n  </body>\n</html>\n");
  return ret
}
function render_authedSLASHpostsSLASHpostDOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <head>\n    <style>\n      html {\n        max-width: 70ch;\n        padding: 3em 1em;\n        margin: auto;\n        line-height: 1.75;\n        font-size: 1.25em;\n      }\n      h1,h2,h3,h4,h5,h6 {\n        margin: 3em 0 1em;\n      }\n      p,ul,ol {\n        margin-bottom: 2em;\n        color: #1d1d1d;\n        font-family: sans-serif;\n      }\n    </style>\n  </head>\n  <body>\n    <h1>");
  ret = ret sprintf("%s",  v["title"]);
  ret = ret sprintf("%s", "</h1>\n    <p>");
  ret = ret sprintf("%s",  v["content"]);
  ret = ret sprintf("%s", "</p>\n  </body>\n</html>\n");
  return ret
}
function render_authedSLASHpostsSLASHnewSLASHgetDOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <head>\n    <style>\n      html {\n        max-width: 70ch;\n        padding: 3em 1em;\n        margin: auto;\n        line-height: 1.75;\n        font-size: 1.25em;\n      }\n      h1,h2,h3,h4,h5,h6 {\n        margin: 3em 0 1em;\n      }\n      p,ul,ol {\n        margin-bottom: 2em;\n        color: #1d1d1d;\n        font-family: sans-serif;\n      }\n    </style>\n  </head>\n  <body>\n    <h1>hello, awkblog!</h1>\n    <div>username: ");
  ret = ret sprintf("%s",  v["username"]);
  ret = ret sprintf("%s", "</div>\n    <form action=\"/authed/posts\" method=\"post\">\n      <div><label>title:<br><input type=\"text\" name=\"title\"></label></div>\n      <div><label>content:<br><textarea name=\"content\"></textarea></label></div>\n      <input type=\"hidden\" name=\"zpadding\" value=\"0\">\n      <div><input type=\"submit\" value=\"投稿する\"></div>\n    </form>\n  </body>\n</html>\n\n");
  return ret
}
function render_authedSLASHpostsSLASHgetDOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <head>\n    <style>\n      html {\n        max-width: 70ch;\n        padding: 3em 1em;\n        margin: auto;\n        line-height: 1.75;\n        font-size: 1.25em;\n      }\n      h1,h2,h3,h4,h5,h6 {\n        margin: 3em 0 1em;\n      }\n      p,ul,ol {\n        margin-bottom: 2em;\n        color: #1d1d1d;\n        font-family: sans-serif;\n      }\n    </style>\n  </head>\n  <body>\n    <h1>posts</h1>\n      ");
 for(i in v["posts"]) { 
  ret = ret sprintf("%s", "\n        <article>\n          <h2>");
  ret = ret sprintf("%s",  v["posts"][i]["title"]);
  ret = ret sprintf("%s", "</h2>\n          <div class=\"date\">");
  ret = ret sprintf("%s",  v["posts"][i]["created_at"]);
  ret = ret sprintf("%s", "</div>\n          <p>");
  ret = ret sprintf("%s",  v["posts"][i]["content"]);
  ret = ret sprintf("%s", "</p>\n        </article>\n      ");
 } 
  ret = ret sprintf("%s", "\n    <a href=\"/authed\">/authed</a>\n  </body>\n</html>\n");
  return ret
}
function render_authedSLASHgetDOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <body>\n    <header>\n      <nav>\n        <ul>\n          <li><a href=\"/authed\">/authed</a></li>\n          <li><a href=\"/authed/posts\">/authed/posts</a></li>\n          <li><a href=\"/authed/posts/new\">/authed/posts/new</a></li>\n          <li><a href=\"/\">/</a></li>\n          <li>\n            <form method=\"POST\" action=\"/logout\">\n              <input type=\"submit\" value=\"logout\">\n            </form>\n          </li>\n        </ul>\n      </nav>\n    </header>\n    <h1>hello, awkblog!</h1>\n    <div>Hi! ");
  ret = ret sprintf("%s",  v["username"]);
  ret = ret sprintf("%s", ", Welcome to awkblog!</div>\n  </body>\n</html>\n");
  return ret
}
function render_404DOThtml(v    , ret) {
  ret = ret sprintf("%s", "<html>\n  <body>\n    404 Not Found\n  </body>\n</html>\n");
  return ret
}
