@include "src/lib/aes256.awk"
@include "src/lib/base64.awk"
@include "test/testutil.awk"

"aes256Encrypt" {
  encrypted = aes256::encrypt("secret information")
  decrypted = aes256::decrypt(encrypted)
  assertEqual("secret information", decrypted)
}

"aes256Decrypt" {
  encrypted = "U2FsdGVkX1-GoTdd5307fxvzI5Yqu7wFMFXv6-lwDAW8E8AYSWs__bGzsVlL4nQG"
  # U2FsdGVkX1+GoTdd5307fxvzI5Yqu7wFMFXv6+lwDAW8E8AYSWs//bGzsVlL4nQG
  decrypted = aes256::decrypt(encrypted)
  assertEqual("secret information", decrypted)
}
