@include "src/json.awk"
@include "test.awk"

{
  assertEqual("yammerjp", json_extract("{ \"hoge\": 3, \"username\": \"yammerjp\" }", "username"))
}
