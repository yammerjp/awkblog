@namespace "url"

function decodeWwwForm(encodedStr,    encodedParts, key, value, equalIndex) {
  delete url::params
  split(encodedStr, encodedParts, "&");

  for (i in encodedParts) {
    if (encodedParts[i] == "") {
      continue
    }
    key = encodedParts[i]
    value = ""

    # split =
    equalIndex = index(key, "=")
    if (equalIndex > 0) {
      value = substr(key, equalIndex + 1)
      key = substr(key, 1, equalIndex - 1)
    }

    # replace +
    gsub("+", " ", key)
    gsub("+", " ", value)

    # utf-8 percent decode
    key = decodeUtf8ParcentEncoding(key)
    value = decodeUtf8ParcentEncoding(value)
    url::params[key] = value
  }
}

function decodeUtf8ParcentEncoding(encodedStr,    chars, decodedStr, L, N, num, utf32num) {
  L = length(encodedStr)
  N = 1
  decodedStr = ""
  split(encodedStr, chars, "")
  while (N<=L) {
    if (chars[N] != "%" || N+2 > L) {
      decodedStr = decodedStr chars[N]
      N++
      continue
    }

    # TODO: byte sequence verificaction
    if (chars[N+1] ~ /^[0-7]$/ ) {
      # 0xxxxxxx
      decodedStr = sprintf("%s%c", decodedStr, awk::strtonum("0x" chars[N+1] chars[N+2]))
      N+=3
    } else if (chars[N+1] ~ /^[c-dC-D]$/ && chars[N+3] = "%") {
      # 110xxxxx 10xxxxxx
      decodedStr = sprintf("%s%c%c", decodedStr, awk::strtonum("0x" chars[N+1] chars[N+2]), awk::strtonum("0x" chars[N+4] chars[N+5]))
      N+=6
    } else if (chars[N+1] ~ /^[eE]$/ && chars[N+3] == "%" && chars[N+6] == "%") {
      # 1110xxxx 10xxxxxx 10xxxxxx
      decodedStr = sprintf("%s%c%c%c", decodedStr, awk::strtonum("0x" chars[N+1] chars[N+2]), awk::strtonum("0x" chars[N+4] chars[N+5]), awk::strtonum("0x" chars[N+7] chars[N+8]))
      N+=9
    } else if (chars[N+1] ~ /^[fF]$/ && chars[N+3] == "%" && chars[N+6] == "%" && chars[N+9] == "%") {
      # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
      decodedStr = sprintf("%s%c%c%c%c", decodedStr, awk::strtonum("0x" chars[N+1] chars[N+2]), awk::strtonum("0x" chars[N+4] chars[N+5]), awk::strtonum("0x" chars[N+7] chars[N+8]), awk::strtonum("0x" chars[N+10] chars[N+11]))
      N+=12
    } else {
      print "failed"
      exit
    }
  }
  return decodedStr
}
