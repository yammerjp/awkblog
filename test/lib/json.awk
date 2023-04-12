@include "src/lib/json.awk"
@include "testutil.awk"

{
  assertEqual("yammerjp", lib::jsonExtractString("{ \"hoge\": 3, \"username\": \"yammerjp\" }", "username"))
}
