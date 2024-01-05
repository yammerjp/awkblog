@load "json"
@namespace "controller"

function api__v1__images__uploading_sign__post(    req) {
  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()

  json::from_json(http::HTTP_REQUEST["body"], req)

  type = req["type"]
  key = "awkblog/accounts/" accountId "/" req["name"]

  now = awk::systime()
  sizeMin = req["size"]
  sizeMax = req["size"]

  http::setHeader("content-type", "application/json")
  http::send(200, awss3::buildPreSignedUploadParams(now, key, type, sizeMin, sizeMax    ))
}
