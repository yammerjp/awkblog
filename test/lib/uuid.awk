@include "src/lib/uuid.awk"
@include "testutil.awk"

"uuid" {
  generated1 = lib::uuid()
  assertEqual(1, generated1 ~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/)
}
