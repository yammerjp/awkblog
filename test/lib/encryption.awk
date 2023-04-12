@include "src/lib/encryption.awk"
@include "src/lib/base64.awk"
@include "testutil.awk"

"aes256Encrypt" {
  encrypted = lib::aes256Encrypt("secret information")
  decrypted = lib::aes256Decrypt(encrypted)
  assertEqual("secret information", decrypted)
}

"aes256Decrypt" {
  encrypted = "U2FsdGVkX1-GoTdd5307fxvzI5Yqu7wFMFXv6-lwDAW8E8AYSWs__bGzsVlL4nQG"
  # U2FsdGVkX1+GoTdd5307fxvzI5Yqu7wFMFXv6+lwDAW8E8AYSWs//bGzsVlL4nQG
  decrypted = lib::aes256Decrypt(encrypted)
  assertEqual("secret information", decrypted)
}

"base64ToUrlsafe" {
  base64 = "U2FsdGVkX1+T/ZtrrVXETUKzKs0DjeeKSeAEF6G+rdY="
  base64url = "U2FsdGVkX1-T_ZtrrVXETUKzKs0DjeeKSeAEF6G-rdY"
  assertEqual(base64url, base64::urlsafe(base64))
}

"base64ToUrlunsafe" {
  base64 = "U2FsdGVkX1+T/ZtrrVXETUKzKs0DjeeKSeAEF6G+rdY="
  base64url = "U2FsdGVkX1-T_ZtrrVXETUKzKs0DjeeKSeAEF6G-rdY"
  assertEqual(base64, base64::urlunsafe(base64url))
}
