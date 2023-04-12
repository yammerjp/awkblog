@include "src/lib/commandExec.awk"
@include "testutil.awk"

{
  assertEqual("hoge\nfuga\n", lib::commandExec("echo \"hoge\nfuga\""))
}
