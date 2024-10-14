@namespace "awss3"

BEGIN {
  loadEnviron()
}

function loadEnviron() {
  NOT_USE_AWS_S3 = environ::get("NOT_USE_AWS_S3")
  if (NOT_USE_AWS_S3) {
    logger::info("The environment variable NOT_USE_AWS_S3 is set; remove this environment variable if you want to use S3.")
  } else {
    logger::info("S3 will be used. If you do not use it, set the environment variable NOT_USE_AWS_S3")
    ACCESS_KEY_ID = environ::getOrPanic("AWS_ACCESS_KEY_ID")
    BUCKET = environ::getOrPanic("AWS_BUCKET")
    REGION = environ::getOrPanic("AWS_REGION")
    SECRET_ACCESS_KEY = environ::getOrPanic("AWS_SECRET_ACCESS_KEY")
    ENDPOINT = environ::getOrPanic("S3_BUCKET_ENDPOINT")
    ASSET_HOST = environ::getOrPanic("S3_ASSET_HOST")
  }
}

function needToUseAwsS3() {
  if (NOT_USE_AWS_S3) {
    error::raise("need to use aws s3", "awss3")
  }
}

function buildPolicyToUpload(now, key, type, sizeMin, sizeMax    , policy) {
  policy["expiration"] = datetime::gmdate("%Y-%m-%dT%H:%M:%S.000Z", now + 60)
  policy["conditions"][1]["bucket"] = BUCKET
  policy["conditions"][2]["key"] = key
  policy["conditions"][3]["Content-Type"] = type
  policy["conditions"][4][1] = "content-length-range"
  policy["conditions"][4][2] = sizeMin
  policy["conditions"][4][3] = sizeMax
  policy["conditions"][5]["acl"] = "public-read"
  policy["conditions"][6]["success_action_status"] = "201"
  policy["conditions"][7]["x-amz-algorithm"] = "AWS4-HMAC-SHA256"
  policy["conditions"][8]["x-amz-credential"] = ACCESS_KEY_ID "/" datetime::gmdate("%Y%m%d", now) "/" REGION "/s3/aws4_request"
  policy["conditions"][9]["x-amz-date"] = datetime::gmdate("%Y%m%dT%H%M%SZ", now)

  return json::to_json(policy, 1)
}

function buildEncodedPolicyToUpload(now, key, type, sizeMin, sizeMax    , policy) {
  return base64::encode(buildPolicyToUpload(now, key, type, sizeMin, sizeMax))
}

function buildDateRegionKey(now) {
  return hmac::sha256(REGION, "hexkey:" hmac::sha256(datetime::gmdate("%Y%m%d", now), "key:AWS4" SECRET_ACCESS_KEY))
}

function sign(signee, now,     dateRegionKey, dateRegionServiceKey, signingKey) {
  dateRegionKey = buildDateRegionKey(now)
  dateRegionServiceKey = hmac::sha256("s3", "hexkey:" dateRegionKey)
  signingKey = hmac::sha256("aws4_request", "hexkey:" dateRegionServiceKey)

  return hmac::sha256(signee, "hexkey:" signingKey)
}

function buildPreSignedUploadParams(now, key, type, sizeMin, sizeMax    , ret, stringToSign) {
  needToUseAwsS3()

  stringToSign = base64::encode(buildPolicyToUpload(now, key, type, sizeMin, sizeMax))
  gsub("\n", "", stringToSign)

  ret["upload_url"] = ENDPOINT # "https://" BUCKET ".s3.amazonaws.com"
  ret["public_url"] = ASSET_HOST "/" key # "https://" BUCKET ".s3.amazonaws.com/" key
  ret["data"]["bucket"] = BUCKET
  ret["data"]["key"] = key
  ret["data"]["acl"] = "public-read"
  ret["data"]["success_action_status"] = "201"
  ret["data"]["policy"] = stringToSign
  ret["data"]["x-amz-credential"] = ACCESS_KEY_ID "/" datetime::gmdate("%Y%m%d", now) "/" REGION "/s3/aws4_request"
  ret["data"]["x-amz-signature"] = sign(stringToSign, now)
  ret["data"]["x-amz-algorithm"] = "AWS4-HMAC-SHA256"
  ret["data"]["x-amz-date"] = datetime::gmdate("%Y%m%dT%H%M%SZ", now)
  ret["data"]["Content-Type"] = type
  return json::to_json(ret)
}
