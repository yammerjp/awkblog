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

# INTERNAL: filepath must be a server-generated safe path
function hashFile(filepath,    cmd, ret, splitted) {
  cmd = "openssl dgst -sha256 -hex " filepath
  ret = shell::exec(cmd)
  split(ret, splitted, " ")
  gsub(/\n/, "", splitted[2])
  return splitted[2]
}

function sha256hash(str,    ret, splitted) {
  ret = shell::exec("openssl dgst -sha256 -hex", str)
  split(ret, splitted, " ")
  gsub(/\n/, "", splitted[2])
  return splitted[2]
}

function extractHost(endpoint,    tmp) {
  tmp = endpoint
  sub(/^https?:\/\//, "", tmp)
  sub(/\/.*$/, "", tmp)
  sub(/:.*$/, "", tmp)
  return tmp
}

function buildCanonicalRequest(method, key, contentType, contentHash, amzDate,    host, canonicalUri, canonicalQueryString, canonicalHeaders, signedHeaders) {
  host = extractHost(ENDPOINT)
  canonicalUri = "/" BUCKET "/" key
  canonicalQueryString = ""
  canonicalHeaders = "content-type:" contentType "\n" \
                     "host:" host "\n" \
                     "x-amz-content-sha256:" contentHash "\n" \
                     "x-amz-date:" amzDate "\n"
  signedHeaders = "content-type;host;x-amz-content-sha256;x-amz-date"

  return method "\n" \
         canonicalUri "\n" \
         canonicalQueryString "\n" \
         canonicalHeaders "\n" \
         signedHeaders "\n" \
         contentHash
}

function buildStringToSign(amzDate, dateStamp, canonicalRequestHash) {
  return "AWS4-HMAC-SHA256\n" \
         amzDate "\n" \
         dateStamp "/" REGION "/s3/aws4_request\n" \
         canonicalRequestHash
}

# Server-side upload to S3
# IMPORTANT: All parameters must be server-generated values to prevent command injection.
# - filepath: temporary file path (e.g., /tmp/ogp_123_456.png)
# - key: S3 object key (e.g., ogp/123/456.png)
# - contentType: MIME type (e.g., image/png)
# DO NOT pass user input directly to these parameters.
function upload(filepath, key, contentType,
    now, amzDate, dateStamp, contentHash, canonicalRequest,
    canonicalRequestHash, stringToSign, signature, authHeader, cmd, host, url) {

  needToUseAwsS3()

  now = awk::systime()
  amzDate = datetime::gmdate("%Y%m%dT%H%M%SZ", now)
  dateStamp = datetime::gmdate("%Y%m%d", now)

  contentHash = hashFile(filepath)

  canonicalRequest = buildCanonicalRequest("PUT", key, contentType, contentHash, amzDate)

  canonicalRequestHash = sha256hash(canonicalRequest)

  stringToSign = buildStringToSign(amzDate, dateStamp, canonicalRequestHash)

  signature = sign(stringToSign, now)

  host = extractHost(ENDPOINT)
  authHeader = "AWS4-HMAC-SHA256 Credential=" ACCESS_KEY_ID "/" dateStamp "/" REGION "/s3/aws4_request, SignedHeaders=content-type;host;x-amz-content-sha256;x-amz-date, Signature=" signature

  url = ENDPOINT "/" BUCKET "/" key

  cmd = "curl -s -X PUT " \
        "-H 'Content-Type: " contentType "' " \
        "-H 'Host: " host "' " \
        "-H 'x-amz-date: " amzDate "' " \
        "-H 'x-amz-content-sha256: " contentHash "' " \
        "-H 'Authorization: " authHeader "' " \
        "--data-binary @" filepath " " \
        "'" url "'"

  shell::exec(cmd)

  return ASSET_HOST "/" key
}
