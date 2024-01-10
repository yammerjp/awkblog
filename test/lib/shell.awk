@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "test/testutil.awk"
@include "src/lib/environ.awk"

{
  assertEqual("hoge\nfuga", shell::exec("echo \"hoge\nfuga\""))
}
