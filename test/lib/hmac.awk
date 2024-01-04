@include "test/testutil.awk"
@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "src/lib/json.awk"
@include "src/lib/base64.awk"
@include "src/lib/hmac.awk"

"hashHex" {
  assertEqual("a0f43328cd36e3d02970fafc2649f4b43edb81b399f615e334be2b4c3ec14302", hmac::sha256("20240104", "key:AWS4secretKey"))
}

"hmacTwice" {
  assertEqual("195f75652ec679550c3eea897a42ccb812d76991c5e5803aab1f2c01d99e6412", hmac::sha256("ap-northeast-1", "hexkey:a0f43328cd36e3d02970fafc2649f4b43edb81b399f615e334be2b4c3ec14302"))

}


