@namespace "html"

function escape(str) {
  gsub(/&/, "\\&amp;", str)
  gsub(/'/, "\\&#x27;", str)
  gsub(/"/, "\\&quot;", str)
  gsub(/</, "\\&lt;", str)
  gsub(/>/, "\\&gt;", str)
  return str
}

