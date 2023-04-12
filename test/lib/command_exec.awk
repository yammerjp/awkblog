@include "src/lib/shell.awk"
@include "testutil.awk"

{
  assertEqual("hoge\nfuga\n", shell::exec("echo \"hoge\nfuga\""))
}
