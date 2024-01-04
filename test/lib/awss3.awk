@include "test/testutil.awk"
@include "src/lib/datetime.awk"
@include "src/lib/awss3.awk"
@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "src/lib/json.awk"

"buildPolicyJson" {
  result = awss3::buildPolicyToUpload( 1704377552, "path/to/image.jpg", "image/jpeg", 1234, "bucketname", "accesskeyid", "secretkey", "public-read", "ap-northeast-1")
  assertEqual("{\"conditions\":[{\"bucket\":\"bucketname\"},{\"key\":\"path/to/image.jpg\"},{\"Content-Type\":\"image/jpeg\"},[\"content-length-range\",1234,1234],{\"acl\":\"public-read\"},{\"success_action_status\":\"201\"},{\"x-amz-algorithm\":\"AWS4-HMAC-SHA256\"},{\"x-amz-credential\":\"accesskeyid/20240104/ap-northeast-1/s3/aws4_request\"},{\"x-amz-date\":\"20240104T141232Z\"}],\"expiration\":\"2024-01-04T14:13:32.000Z\"}", result)
}
