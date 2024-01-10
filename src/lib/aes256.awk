@namespace "aes256"

function encrypt(str        , cmd, ret) {
  if (!(str ~ /^[a-zA-Z0-9_ -]+$/)) {
    error::raise("invalid charactor is included", "aes256")
  }
  cmd = "echo '" str "' | openssl enc -A -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY"
  cmd |& getline ret
  close(cmd)
  return base64::urlsafe(ret)
}

function decrypt(str        , cmd, ret) {
  str = base64::urlunsafe(str)
  if (!(str ~ /^[a-zA-Z0-9+/]+=*$/)) {
    error::raise("aes256::decrypt", "aes256")
  }
  cmd =  "echo '" str "' | openssl enc -d -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY"
  cmd |& getline ret
  close(cmd)
  return ret
}
