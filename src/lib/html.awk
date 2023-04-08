@namespace "lib"

function html_escape(str) {
  gsub(/&/, "\\&amp;", str)
  gsub(/'/, "\\&#x27;", str)
  gsub(/"/, "\\&#x60;", str)
  gsub(/</, "\\&lt;", str)
  gsub(/>/, "\\&gt;", str)
  return str
}

