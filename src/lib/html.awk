@namespace "lib"

function htmlEscape(str) {
  gsub(/&/, "\\&amp;", str)
  gsub(/'/, "\\&#x27;", str)
  gsub(/"/, "\\&#x60;", str)
  gsub(/</, "\\&lt;", str)
  gsub(/>/, "\\&gt;", str)
  return str
}

