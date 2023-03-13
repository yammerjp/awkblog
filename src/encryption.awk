# $ echo "Secret Information" | ENCRYPTION_KEY="hogefuga" openssl enc -e -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY > secret.txt
# $ cat secret.txt | ENCRYPTION_KEY="hogefuga" openssl enc -d -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY

# $ echo ":hello:world:hoge:fuga" | ENCRYPTION_KEY=tqOEDSfSPctvuBtvRkqcRjnqJHMGtgyc awk -f encryption.awk
# U2FsdGVkX1+DnuxzKBE0EY/NBwlY5fghJPM8Yu0jTuXMiXGt4/DGXOEjdKbseDsJ
# $ echo "U2FsdGVkX1+DnuxzKBE0EY/NBwlY5fghJPM8Yu0jTuXMiXGt4/DGXOEjdKbseDsJ" | ENCRYPTION_KEY=tqOEDSfSPctvuBtvRkqcRjnqJHMGtgyc awk -f encryption.awk
# :hello:world:hoge:fuga

function aes256_encrypt(str,  cmd, ret) {
  if (!(str ~ /^[a-zA-Z0-9:]+$/)) {
    return ""
  }
  cmd = "echo '" str "' | openssl enc -e -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY"
  cmd |& getline ret
  close(cmd)
  return ret
}

function aes256_decrypt(str,  cmd, ret) {
  if (!(str ~ /^[a-zA-Z0-9+\/]+$/)) {
    return ""
  }
  cmd =  "echo '" str "' | openssl enc -d -base64 -aes-256-cbc -salt -pbkdf2 -pass env:ENCRYPTION_KEY"
  cmd |& getline ret
  close(cmd)
  return ret
}

# /^:/{
#   print aes256_encrypt($0)
#   }
# /^[^:]/ {
#   print aes256_decrypt($0)
# }
