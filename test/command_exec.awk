@include "src/command_exec.awk"
@include "test.awk"

{
  assertEqual("hoge\nfuga\n", command_exec("echo \"hoge\nfuga\""))
}
