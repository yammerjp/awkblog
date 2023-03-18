@namespace "lib"

function json_extract(json_str, key,    splitted) {
  split(json_str, splitted, "\"")
  for (i = 1; i<=length(splitted);i++) {
    if (splitted[i] == key) {
      return splitted[i+2]
    }
  }
  return ""
}
