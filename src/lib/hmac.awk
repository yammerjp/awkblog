@namespace "hmac"

function sha256(value, secret    , splitted, ret) {
  if (secret !~ /^key:[a-zA-Z0-9+/]+$/ && secret !~/^hexkey:[a-fA-F0-9]+$/) {
    logger::error("the secret is invalid: " secret)
    exit 1
  }
  ret = shell::exec("openssl dgst -sha256 -mac HMAC -macopt \"" secret "\"", value)
  split(ret, splitted, " ")
  return splitted[2]
}
