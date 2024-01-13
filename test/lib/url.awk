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
  url::decodewwwform(result, "foo=bar&hello=world&jp=%e3%81%82")
  assertequal(3, length(result))
  assertequal("bar", result["foo"])
  assertequal("world", result["hello"])
  assertequal("あ", result["jp"])
}

# post_id=246&title=aaa&content=aaa&zpadding=0
# post_id=246&title=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF&content=%E3%81%8A%E3%81%AF%E3%82%88%E3%81%86%E3%81%94%E3%81%96%E3%81%84%E3%81%BE%E3%81%99&zpadding=0
