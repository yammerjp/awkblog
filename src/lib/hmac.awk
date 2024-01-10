@namespace "hmac"

function sha256(value, secret    , splitted, ret) {
  if (secret !~ /^key:[a-zA-Z0-9+/]+$/ && secret !~/^hexkey:[a-fA-F0-9]+$/) {
    error::panic("secret is invalid")
  }
  ret = shell::exec("openssl dgst -sha256 -mac HMAC -macopt \"" secret "\"", value)
  split(ret, splitted, " ")
  return splitted[2]
}
