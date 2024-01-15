@namespace "html"

function escape(str) {
  gsub(/&/, "\\&amp;", str)
  gsub(/'/, "\\&#x27;", str)
  gsub(/"/, "\\&quot;", str)
  gsub(/</, "\\&lt;", str)
  gsub(/>/, "\\&gt;", str)
  return str
}

function toText(content    , chars, inTag, i ,ret) {
  ret = ""
  inTag = 0
  split(content, chars, "")
  for (i in chars) {
    if (chars[i] == "<") {
      inTag = 1
      continue
    }
    if (chars[i] == ">") {
      inTag = 0
      continue
    }
    if (inTag) {
      continue
    }
    ret = ret chars[i]
  }
  return ret
}

