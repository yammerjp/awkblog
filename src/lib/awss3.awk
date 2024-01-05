@namespace "awss3"

function getAccessKey() {
  return ENVIRON["AWS_ACCESS_KEY_ID"]
}
function getBucket() {
  return ENVIRON["AWS_BUCKET"]
}
function getRegion() {
  return ENVIRON["AWS_REGION"]
}
function getAccessSecret() {
  return ENVIRON["AWS_SECRET_ACCESS_KEY"]
}
function buildPolicyToUpload(now, key, type, sizeMin, sizeMax    , policy) {
  policy["expiration"] = datetime::gmdate("%Y-%m-%dT%H:%M:%S.000Z", now + 60)
  policy["conditions"][1]["bucket"] = getBucket()
  policy["conditions"][2]["key"] = key
  policy["conditions"][3]["Content-Type"] = type
  policy["conditions"][4][1] = "content-length-range"
  policy["conditions"][4][2] = sizeMin
  policy["conditions"][4][3] = sizeMax
  policy["conditions"][5]["acl"] = "public-read"
  policy["conditions"][6]["success_action_status"] = "201"
  policy["conditions"][7]["x-amz-algorithm"] = "AWS4-HMAC-SHA256"
  policy["conditions"][8]["x-amz-credential"] = getAccessKey() "/" datetime::gmdate("%Y%m%d", now) "/" getRegion() "/s3/aws4_request"
  policy["conditions"][9]["x-amz-date"] = datetime::gmdate("%Y%m%dT%H%M%SZ", now)

  return json::to_json(policy, 1)
}

function buildEncodedPolicyToUpload(now, key, type, sizeMin, sizeMax    , policy) {
  return base64::encode(buildPolicyToUpload(now, key, type, sizeMin, sizeMax))
}

function buildDateRegionKey(now) {
  return hmac::sha256(getRegion(), "hexkey:" hmac::sha256(datetime::gmdate("%Y%m%d", now), "key:AWS4" getAccessSecret()))
}

function sign(signee, now) {
  dateRegionKey = buildDateRegionKey(now)
  dateRegionServiceKey = hmac::sha256("s3", "hexkey:" dateRegionKey)
  signingKey = hmac::sha256("aws4_request", "hexkey:" dateRegionServiceKey)

  return hmac::sha256(signee, "hexkey:" signingKey)
}

function buildPreSignedUploadParams(now, key, type, sizeMin, sizeMax    , ret) {
  stringToSign = base64::encode(buildPolicyToUpload(now, key, type, sizeMin, sizeMax))
  gsub("\n", "", stringToSign)

  ret["upload_url"] = "https://" getBucket() ".s3.amazonaws.com"
  ret["public_url"] = "https://" getBucket() ".s3.amazonaws.com/" key
  ret["data"]["bucket"] = getBucket()
  ret["data"]["key"] = key
  ret["data"]["acl"] = "public-read"
  ret["data"]["success_action_status"] = "201"
  ret["data"]["policy"] = stringToSign
  ret["data"]["x-amz-credential"] = getAccessKey() "/" datetime::gmdate("%Y%m%d", now) "/" getRegion() "/s3/aws4_request"
  ret["data"]["x-amz-signature"] = sign(stringToSign, now)
  ret["data"]["x-amz-algorithm"] = "AWS4-HMAC-SHA256"
  ret["data"]["x-amz-date"] = datetime::gmdate("%Y%m%dT%H%M%SZ", now)
  ret["data"]["Content-Type"] = type
  return json::to_json(ret)
}
