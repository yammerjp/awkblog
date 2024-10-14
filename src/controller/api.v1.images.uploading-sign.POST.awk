@load "json"
@namespace "controller"

function api__v1__images__uploading_sign__post(    req, accountId, type, extension, now, key, sizeMin, sizeMax) {
  auth::forbiddenIfFailedToVerify()
  accountId = auth::getAccountId()

  json::from_json(http::HTTP_REQUEST["body"], req)

  type = req["type"]
  switch(type) {
    case "image/png":
      extension = "png"
      break
    case "image/jpeg":
      extension = "jpg"
      break
    case "image/gif":
      extension = "gif"
      break
    case "image/webp":
      extension = "webp"
      break
    default:
      http::send(400, "unknown file type")
      return
  }

  now = awk::systime()

  key = "img/" accountId "/" now substr(http::getRequestId(), 1, 8) "." extension

  sizeMin = 32
  sizeMax = 1024 * 1024 * 3

  http::setHeader("content-type", "application/json")
  http::send(200, awss3::buildPreSignedUploadParams(now, key, type, sizeMin, sizeMax    ))
}
