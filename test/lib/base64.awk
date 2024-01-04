@include "src/lib/logger.awk"
@include "src/lib/shell.awk"
@include "src/lib/base64.awk"
@include "test/testutil.awk"

"base64Encode" {
  encoded = base64::encode("hello, world!")
  assertEqual("aGVsbG8sIHdvcmxkIQ==", encoded)
}

"base64Decode" {
  decoded = base64::decode("aGVsbG8sIHdvcmxkIQ==")
  assertEqual("hello, world!", decoded)
}

"base64EncodeAndDecode" {
  encoded = base64::encode("secret information")
  decoded = base64::decode(encoded)
  assertEqual("secret information", decoded)
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
