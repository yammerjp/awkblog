# $ echo "Secret Information" | ENCRYPTION_KEY="hogefuga" openssl enc -e -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY > secret.txt
# $ cat secret.txt | ENCRYPTION_KEY="hogefuga" openssl enc -d -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY

# $ echo ":hello:world:hoge:fuga" | ENCRYPTION_KEY=tqOEDSfSPctvuBtvRkqcRjnqJHMGtgyc awk -f encryption.awk
# U2FsdGVkX1+DnuxzKBE0EY/NBwlY5fghJPM8Yu0jTuXMiXGt4/DGXOEjdKbseDsJ
# $ echo "U2FsdGVkX1+DnuxzKBE0EY/NBwlY5fghJPM8Yu0jTuXMiXGt4/DGXOEjdKbseDsJ" | ENCRYPTION_KEY=tqOEDSfSPctvuBtvRkqcRjnqJHMGtgyc awk -f encryption.awk
# :hello:world:hoge:fuga

@namespace "lib"

function aes256Encrypt(str        , cmd, ret) {
  if (!(str ~ /^[a-zA-Z0-9_ -]+$/)) {
    print "[Error]: invalid charactor is included"
    return ""
  }
  cmd = "echo '" str "' | openssl enc -A -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY"
  cmd |& getline ret
  close(cmd)
  return base64::urlsafe(ret)
}

function aes256Decrypt(str        , cmd, ret) {
  str = base64::urlunsafe(str)
  if (!(str ~ /^[a-zA-Z0-9+/]+=*$/)) {
    print "[Error]: aes256Decrypt"
    return ""
  }
  cmd =  "echo '" str "' | openssl enc -d -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY"
  cmd |& getline ret
  close(cmd)
  return ret
}
