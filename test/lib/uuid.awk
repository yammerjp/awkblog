@include "src/lib/uuid.awk"
@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "test/testutil.awk"
@include "src/lib/environ.awk"

"uuid" {
  generated1 = uuid::gen()
  assertEqual(1, generated1 ~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/)
}
