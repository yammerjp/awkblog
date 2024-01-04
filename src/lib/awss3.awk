@namespace "awss3"

function buildPolicyToUpload(now, key, type, size, bucket, accessKey, secretKey, acl, region    , policy) {
  policy["expiration"] = datetime::gmdate("%Y-%m-%dT%H:%M:%S.000Z", now + 60)
  policy["conditions"][1]["bucket"] = bucket
  policy["conditions"][2]["key"] = key
  policy["conditions"][3]["Content-Type"] = type
  policy["conditions"][4][1] = "content-length-range"
  policy["conditions"][4][2] = size
  policy["conditions"][4][3] = size
  policy["conditions"][5]["acl"] = "public-read"
  policy["conditions"][6]["success_action_status"] = "201"
  policy["conditions"][7]["x-amz-algorithm"] = "AWS4-HMAC-SHA256"
  policy["conditions"][8]["x-amz-credential"] = accessKey "/" datetime::gmdate("%Y%m%d", now) "/" region "/s3/aws4_request"
  policy["conditions"][9]["x-amz-date"] = datetime::gmdate("%Y%m%dT%H%M%SZ", now)

  return json::to_json(policy, 1)
}
