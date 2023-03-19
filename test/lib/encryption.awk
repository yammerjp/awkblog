@include "src/lib/encryption.awk"
@include "testutil.awk"

"aes256_encrypt" {
  encrypted = lib::aes256_encrypt("secret information")
  decrypted = lib::aes256_decrypt(encrypted)
  assertEqual("secret information", decrypted)
}

"aes256_decrypt" {
  encrypted = "U2FsdGVkX1-GoTdd5307fxvzI5Yqu7wFMFXv6-lwDAW8E8AYSWs__bGzsVlL4nQG"
  # U2FsdGVkX1+GoTdd5307fxvzI5Yqu7wFMFXv6+lwDAW8E8AYSWs//bGzsVlL4nQG
  decrypted = lib::aes256_decrypt(encrypted)
  assertEqual("secret information", decrypted)
}

"base64_to_urlsafe" {
  base64 = "U2FsdGVkX1+T/ZtrrVXETUKzKs0DjeeKSeAEF6G+rdY="
  base64url = "U2FsdGVkX1-T_ZtrrVXETUKzKs0DjeeKSeAEF6G-rdY"
  assertEqual(base64url, lib::base64_to_urlsafe(base64))
}

"base64_to_urlunsafe" {
  base64 = "U2FsdGVkX1+T/ZtrrVXETUKzKs0DjeeKSeAEF6G+rdY="
  base64url = "U2FsdGVkX1-T_ZtrrVXETUKzKs0DjeeKSeAEF6G-rdY"
  assertEqual(base64, lib::base64_to_urlunsafe(base64url))
}
