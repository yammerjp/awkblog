@include "src/lib/json.awk"
@include "testutil.awk"

{
  assertEqual("yammerjp", lib::json_extract("{ \"hoge\": 3, \"username\": \"yammerjp\" }", "username"))
}
