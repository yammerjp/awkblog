@namespace "hmac"

function sha256(value, secret) {
  if (secret !~ /^[a-zA-Z0-9+/]+$/) {
    logger::error("the secret includes invalid charactor: ")
    exit 1
  }
  cmd = "openssl dgst -sha256 -hmac \"" secret "\""
  return shell::exec(cmd, value)
}
