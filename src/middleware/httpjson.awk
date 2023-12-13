@namespace "httpjson"

function render(arr, statusNum) {
  http::setHeader("content-type", "application/json")
  if (statusNum == "") {
    statusNum = 200
  }
  return http::send(statusNum, json::to_json(arr, 1))
}

function badRequest(message    , arr) {
  if (message == "") {
    message = "bad request"
  }
  arr["message"] = message
  return render(arr, 400)
}

function notFound(message    , arr) {
  if (message == "") {
    message = "not found"
  }
  arr["message"] = message
  return render(arr, 404)
}

function internalError(message    , arr) {
  if (message == "") {
    message = "internal server error"
  }
  arr["message"] = message
  return render(arr, 500)
}
