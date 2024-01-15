@include "src/lib/url.awk"
@include "src/lib/logger.awk"
@include "src/lib/environ.awk"
@include "src/lib/error.awk"
@include "test/testutil.awk"

"decodeUtf8ParcentEncoding" {
  assertEqual("hello", url::decodeUtf8ParcentEncoding("hello"))
  assertEqual(" ", url::decodeUtf8ParcentEncoding("%20"))
  assertEqual("あ", url::decodeUtf8ParcentEncoding("%E3%81%82"))
  assertEqual("😀", url::decodeUtf8ParcentEncoding("%F0%9F%98%80"))
}

"decodewwwform" {
  url::decodeWwwForm(result, "foo=bar&hello=world&jp=%e3%81%82")
  assertEqual(3, length(result))
  assertEqual("bar", result["foo"])
  assertEqual("world", result["hello"])
  assertEqual("あ", result["jp"])
}
