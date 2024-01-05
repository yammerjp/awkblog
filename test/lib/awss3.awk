@include "test/testutil.awk"
@include "src/lib/datetime.awk"
@include "src/lib/awss3.awk"
@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "src/lib/json.awk"
@include "src/lib/base64.awk"
@include "src/lib/hmac.awk"

"buildPolicyJson" {
  ENVIRON["AWS_ACCESS_KEY_ID"] = "accesskeyid"
  ENVIRON["AWS_BUCKET"] = "bucketname"
  ENVIRON["AWS_REGION"] = "ap-northeast-1"

  result = awss3::buildPolicyToUpload(1704377552, "path/to/image.jpg", "image/jpeg", 1234, 1234)
  assertEqual("{\"conditions\":[{\"bucket\":\"bucketname\"},{\"key\":\"path/to/image.jpg\"},{\"Content-Type\":\"image/jpeg\"},[\"content-length-range\",1234,1234],{\"acl\":\"public-read\"},{\"success_action_status\":\"201\"},{\"x-amz-algorithm\":\"AWS4-HMAC-SHA256\"},{\"x-amz-credential\":\"accesskeyid/20240104/ap-northeast-1/s3/aws4_request\"},{\"x-amz-date\":\"20240104T141232Z\"}],\"expiration\":\"2024-01-04T14:13:32.000Z\"}", result)
}

"buildPolicyJsonEncoded" {
  ENVIRON["AWS_ACCESS_KEY_ID"] = "accesskeyid"
  ENVIRON["AWS_BUCKET"] = "bucketname"
  ENVIRON["AWS_REGION"] = "ap-northeast-1"

  result = base64::encode(awss3::buildPolicyToUpload(1704377552, "path/to/image.jpg", "image/jpeg", 1234, 1234))

  assertEqual("eyJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJidWNrZXRuYW1lIn0seyJrZXkiOiJwYXRoL3RvL2ltYWdlLmpwZyJ9LHsiQ29udGVudC1UeXBlIjoiaW1hZ2UvanBlZyJ9LFsiY29udGVudC1sZW5ndGgtcmFuZ2UiLDEyMzQsMTIzNF0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNza2V5aWQvMjAyNDAxMDQvYXAtbm9ydGhlYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1kYXRlIjoiMjAyNDAxMDRUMTQxMjMyWiJ9XSwiZXhwaXJhdGlvbiI6IjIwMjQtMDEtMDRUMTQ6MTM6MzIuMDAwWiJ9", result)

}

"buildDateRegionKey" {
  ENVIRON["AWS_REGION"] = "ap-northeast-1"
  ENVIRON["AWS_SECRET_ACCESS_KEY"] = "secretkey"

  assertEqual("835ae2b2d0f4fbecaf27c58d608b4ffa7d1c248bf0d908255c27f9882926c731", awss3::buildDateRegionKey(1704377552))
}

"sign" {
  ENVIRON["AWS_ACCESS_KEY_ID"] = "accesskeyid"
  ENVIRON["AWS_BUCKET"] = "bucketname"
  ENVIRON["AWS_REGION"] = "ap-northeast-1"
  ENVIRON["AWS_SECRET_ACCESS_KEY"] = "secretkey"

  result = awss3::sign("eyJleHBpcmF0aW9uIjoiMjAyNC0wMS0wNFQxNDoxMzozMi4wMDBaIiwiY29uZGl0aW9ucyI6W3siYnVja2V0IjoiYnVja2V0bmFtZSJ9LHsia2V5IjoicGF0aFwvdG9cL2ltYWdlLmpwZyJ9LHsiQ29udGVudC1UeXBlIjoiaW1hZ2VcL2pwZWcifSxbImNvbnRlbnQtbGVuZ3RoLXJhbmdlIiwxMjM0LDEyMzRdLHsiYWNsIjoicHVibGljLXJlYWQifSx7InN1Y2Nlc3NfYWN0aW9uX3N0YXR1cyI6IjIwMSJ9LHsieC1hbXotYWxnb3JpdGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsieC1hbXotY3JlZGVudGlhbCI6ImFjY2Vzc2tleWlkXC8yMDI0MDEwNFwvYXAtbm9ydGhlYXN0LTFcL3MzXC9hd3M0X3JlcXVlc3QifSx7IngtYW16LWRhdGUiOiIyMDI0MDEwNFQxNDEyMzJaIn1dfQ==", 1704377552)
  assertEqual("9025496f853e2eadf981e9a3a86a013919e553f1859340b4ce9e50c711f8dc83", result)

}

"sign" {
  ENVIRON["AWS_ACCESS_KEY_ID"] = "accesskeyid"
  ENVIRON["AWS_BUCKET"] = "bucketname"
  ENVIRON["AWS_REGION"] = "ap-northeast-1"
  ENVIRON["AWS_SECRET_ACCESS_KEY"] = "secretkey"


  result = awss3::sign("eyJleHBpcmF0aW9uIjoiMjAyNC0wMS0wNFQxNDoxMzozMi4wMDBaIiwiY29uZGl0aW9ucyI6W3siYnVja2V0IjoiYnVja2V0bmFtZSJ9LHsia2V5IjoicGF0aFwvdG9cL2ltYWdlLmpwZyJ9LHsiQ29udGVudC1UeXBlIjoiaW1hZ2VcL2pwZWcifSxbImNvbnRlbnQtbGVuZ3RoLXJhbmdlIiwxMjM0LDEyMzRdLHsiYWNsIjoicHVibGljLXJlYWQifSx7InN1Y2Nlc3NfYWN0aW9uX3N0YXR1cyI6IjIwMSJ9LHsieC1hbXotYWxnb3JpdGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsieC1hbXotY3JlZGVudGlhbCI6ImFjY2Vzc2tleWlkXC8yMDI0MDEwNFwvYXAtbm9ydGhlYXN0LTFcL3MzXC9hd3M0X3JlcXVlc3QifSx7IngtYW16LWRhdGUiOiIyMDI0MDEwNFQxNDEyMzJaIn1dfQ", 1704377552)
  assertEqual("8066001e912f98d4b2cff80ce945eff014fb0535a21326a2858fbc3ac2ff484d", result)

}

"buildPreSignedUploadParams" {
  ENVIRON["AWS_ACCESS_KEY_ID"] = "accesskeyid"
  ENVIRON["AWS_BUCKET"] = "bucketname"
  ENVIRON["AWS_REGION"] = "ap-northeast-1"
  ENVIRON["AWS_SECRET_ACCESS_KEY"] = "secretkey"

  result = awss3::buildPreSignedUploadParams(1704377552, "path/to/image.jpg", "image/jpeg", 1234, 1234)
  assertEqual("{\"public_url\":\"https://bucketname.s3.amazonaws.com/path/to/image.jpg\",\"data\":{\"x-amz-algorithm\":\"AWS4-HMAC-SHA256\",\"acl\":\"public-read\",\"key\":\"path/to/image.jpg\",\"Content-Type\":\"image/jpeg\",\"x-amz-credential\":\"accesskeyid/20240104/ap-northeast-1/s3/aws4_request\",\"bucket\":\"bucketname\",\"policy\":\"eyJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJidWNrZXRuYW1lIn0seyJrZXkiOiJwYXRoL3RvL2ltYWdlLmpwZyJ9LHsiQ29udGVudC1UeXBlIjoiaW1hZ2UvanBlZyJ9LFsiY29udGVudC1sZW5ndGgtcmFuZ2UiLDEyMzQsMTIzNF0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LHsic3VjY2Vzc19hY3Rpb25fc3RhdHVzIjoiMjAxIn0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1jcmVkZW50aWFsIjoiYWNjZXNza2V5aWQvMjAyNDAxMDQvYXAtbm9ydGhlYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1kYXRlIjoiMjAyNDAxMDRUMTQxMjMyWiJ9XSwiZXhwaXJhdGlvbiI6IjIwMjQtMDEtMDRUMTQ6MTM6MzIuMDAwWiJ9\",\"x-amz-signature\":\"025c2c3800b438b4e8633b0a925f260b5c4b1a3d48fd8c6b18965a902a32d414\",\"x-amz-date\":\"20240104T141232Z\",\"success_action_status\":\"201\"},\"upload_url\":\"https://bucketname.s3.amazonaws.com\"}", result)
}
