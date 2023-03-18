@include "src/lib/command_exec.awk"
@include "testutil.awk"

{
  assertEqual("hoge\nfuga\n", lib::command_exec("echo \"hoge\nfuga\""))
}
