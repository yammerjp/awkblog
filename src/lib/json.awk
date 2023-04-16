@namespace "json"

function extractString(jsonStr, key,    splitted) {
  split(jsonStr, splitted, "\"")
  for (i = 1; i<=length(splitted);i++) {
    if (splitted[i] == key) {
      return splitted[i+2]
    }
  }
  return ""
}

function extractNumber(jsonStr, key,        splitted, value) {
  split(jsonStr, splitted, "\"")
  for (i = 1; i<=length(splitted);i++) {
    if (splitted[i] == key) {
      value = splitted[i+1]
      split(value, splitted, ":")
      value = splitted[2]
      split(value, splitted, ",")
      return splitted[1]
      split(value, splitted, "}")
      return splitted[1]
    }
  }
  return ""

}
