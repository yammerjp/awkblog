@namespace "datetime"

function gmdate(format, timestamp    , tzstr, operator, diffH, diffM, diffS, offset) {
  tzstr = awk::strftime("%z")
  if (tzstr !~ /^[-+][0-9]{4}$/) {
    error::raise("failure. strftime(\"%z\") is invalid format:" tzstr, "datetime")
  }
  operator = substr(tzstr,1,1)
  diffH = substr(tzstr, 2,2)
  diffM = substr(tzstr, 4,2)
  diffS = (diffH + 0) * 3600 + (diffS + 0) * 60

  if (operator == "+") {
    offset = - diffS
  } else {
    offset = + diffS
  }
  if (timestamp == 0) {
    timestamp = awk::systime()
  }
  return awk::strftime(format, timestamp + offset)
}
