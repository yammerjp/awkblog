@include "src/lib/json.awk"
@include "testutil.awk"

{
  assertEqual("yammerjp", lib::json_extract_string("{ \"hoge\": 3, \"username\": \"yammerjp\" }", "username"))
}
