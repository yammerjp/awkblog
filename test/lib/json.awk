@include "src/lib/json.awk"
@include "testutil.awk"

{
  assertEqual("yammerjp", json::extractString("{ \"hoge\": 3, \"username\": \"yammerjp\" }", "username"))
}
