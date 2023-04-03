@namespace "lib"

function decode_www_form(encoded_str,    encoded_parts, key, value, equal_index) {
  delete lib::KV
  split(encoded_str, encoded_parts, "&");

  for (i in encoded_parts) {
    if (encoded_parts[i] == "") {
      continue
    }
    key = encoded_parts[i]
    value = ""

    # split =
    equal_index = index(key, "=")
    if (equal_index > 0) {
      value = substr(key, equal_index + 1)
      key = substr(key, 1, equal_index - 1)
    }

    # replace +
    gsub("+", " ", key)
    gsub("+", " ", value)

    # utf-8 percent decode
    key = decode_utf8_parcent_encoding(key)
    value = decode_utf8_parcent_encoding(value)
    lib::KV[key] = value
  }
}

function decode_utf8_parcent_encoding(encoded_str,    chars, decoded_str, L, N, num, utf32num) {
  L = length(encoded_str)
  N = 1
  decoded_str = ""
  split(encoded_str, chars, "")
  while (N<=L) {
    if (chars[N] != "%" || N+2 > L) {
      decoded_str = decoded_str chars[N]
      N++
      continue
    }

    # TODO: byte sequence verificaction
    if (chars[N+1] ~ /^[0-7]$/ ) {
      # 0xxxxxxx
      decoded_str = sprintf("%s%c", decoded_str, strtonum("0x" chars[N+1] chars[N+2]))
      N+=3
    } else if (chars[N+1] ~ /^[c-dC-D]$/ && chars[N+3] = "%") {
      # 110xxxxx 10xxxxxx
      decoded_str = sprintf("%s%c%c", decoded_str, strtonum("0x" chars[N+1] chars[N+2]), strtonum("0x" chars[N+4] chars[N+5]))
      N+=6
    } else if (chars[N+1] ~ /^[eE]$/ && chars[N+3] == "%" && chars[N+6] == "%") {
      # 1110xxxx 10xxxxxx 10xxxxxx
      decoded_str = sprintf("%s%c%c%c", decoded_str, strtonum("0x" chars[N+1] chars[N+2]), strtonum("0x" chars[N+4] chars[N+5]), strtonum("0x" chars[N+7] chars[N+8]))
      N+=9
    } else if (chars[N+1] ~ /^[fF]$/ && chars[N+3] == "%" && chars[N+6] == "%" && chars[N+9] == "%") {
      # 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
      decoded_str = sprintf("%s%c%c%c%c", decoded_str, strtonum("0x" chars[N+1] chars[N+2]), strtonum("0x" chars[N+4] chars[N+5]), strtonum("0x" chars[N+7] chars[N+8]), strtonum("0x" chars[N+10] chars[N+11]))
      N+=12
    } else {
      print "failed"
      exit
    }
  }
  return decoded_str
}
