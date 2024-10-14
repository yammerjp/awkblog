@namespace "url"

function decodeWwwForm(result, encodedStr,    encodedParts, key, value, equalIndex, i) {
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
    result[key] = value
  }
}

function decodeUtf8ParcentEncoding(encodedStr,    chars, decodedStr, l, n, num, utf32num, p1, p2, p3, p4, b1, b2, b3, b4) {
  l = length(encodedStr)
  n = 1
  decodedStr = ""
  split(encodedStr, chars, "")
  while (n<=l) {
    if (chars[n] != "%" || n+2 > l) {
      decodedStr = decodedStr chars[n]
      n++
      continue
    }

    # ref:
    #   http://www.unicode.org/versions/Unicode6.0.0/ch03.pdf
    #   Table 3-7. Well-Formed UTF-8 Byte Sequences

    p1 = chars[n] == "%"
    b1 = awk::strtonum("0x" chars[n+1] chars[n+2])
    p2 = chars[n+3] == "%"
    b2 = awk::strtonum("0x" chars[n+4] chars[n+5])
    p3 = chars[n+6] == "%"
    b3 = awk::strtonum("0x" chars[n+7] chars[n+8])
    p4 = chars[n+9] == "%"
    b4 = awk::strtonum("0x" chars[n+10] chars[n+11])

    if (p1 && 0x00 <= b1 && b1 <= 0x7F) {
      # 0xxxxxxx
      decodedStr = sprintf("%s%c", decodedStr, b1)
      n+=3
      continue
    }
    if (p1 && p2 && \
        0xC2 <= b1 && b1 <= 0xDF    &&     0x80 <= b2 && b2 <= 0xBF \
    ) {
      # 110xxxxx 10xxxxxx
      decodedStr = sprintf("%s%c%c", decodedStr, b1, b2)
      n+=6
      continue
    }
    if (p1 && p2 && p3 && (\
      ( b1 == 0xE0                  &&     0xA0 <= b2 && b2 <= 0xBF    &&    0x80 <= b3 && b3 <= 0xBF ) || \
      ( 0xE1 <= b1 && b1 <= 0xEC    &&     0x80 <= b2 && b2 <= 0xBF    &&    0x80 <= b3 && b3 <= 0xBF ) || \
      ( b1 == 0xED                  &&     0x80 <= b2 && b2 <= 0x9F    &&    0x80 <= b3 && b3 <= 0xBF ) || \
      ( 0xEE <= b1 && b1 <= 0xEF    &&     0x80 <= b2 && b2 <= 0xBF    &&    0x80 <= b3 && b3 <= 0xBF ) \
    )) {
      # 1110xxxx 10xxxxxx 10xxxxxx
      decodedStr = sprintf("%s%c%c%c", decodedStr, b1, b2, b3)
      n+=9
      continue
    }
    if (p1 && p2 && p3 && p4 && ( \
      ( b1 == 0xF0                  &&    0x90 <= b2 && b2 <= 0xBF    &&    0x80 <= b3 && b3 <= 0xBF     &&    0x80 <= b4 && b4 <= 0x80 ) || \
      ( 0xF1 <= b1 && b1 <= 0xF3    &&    0x80 <= b2 && b2 <= 0xBF    &&    0x80 <= b3 && b3 <= 0xBF     &&    0x80 <= b4 && b4 <= 0x80 ) || \
      ( b1 == 0xF4                  &&    0x80 <= b2 && b2 <= 0x8F    &&    0x80 <= b3 && b3 <= 0xBF     &&    0x80 <= b4 && b4 <= 0x80 ) \
    )) {
      # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
      decodedStr = sprintf("%s%c%c%c%c", decodedStr, b1, b2, b3, b4)
      n+=12
      continue
    }
    error::raise("failed to decode UTF-8 parcent encoded string", "url")
    exit 1
  }
  return decodedStr
}
