@namespace "base64"

function urlsafe(str) {
  gsub("+","-", str)
  gsub("/","_", str)
  gsub("=", "", str)
  return str
}

function urlunsafe(str) {
  gsub("-","+", str)
  gsub("_","/", str)
  switch (length(str) % 4) {
    case 0:
      return str
    case 1:
      return str "==="
    case 2:
      return str "=="
    case 3:
      return str "="
  }
}

function encode(str) {
  return shell::exec("openssl enc -e -base64", str)
}

function decode(str) {
  return shell::exec("openssl enc -d -base64", str "\n")
}
