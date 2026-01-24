@namespace "utf8"

# UTF-8 byte handling for POSIX locale (byte-oriented processing)
# This module provides character-based operations on UTF-8 strings
# even when AWK is operating in byte mode (LC_ALL=C / POSIX locale)

# Lookup table for byte values (initialized in _init)
# _ByteVal[char] = byte value (0-255)

function _init(    i, c) {
    # Build byte value lookup table
    for (i = 0; i < 256; i++) {
        c = sprintf("%c", i)
        _ByteVal[c] = i
    }
}

# Get byte value of a single-byte string
function _byteVal(c) {
    return _ByteVal[c]
}

# Get the byte length of a UTF-8 character starting at the given byte
# Returns 1-4 for valid UTF-8 lead bytes, 1 for ASCII, 1 for invalid/continuation
function _charByteLen(leadByte,    val) {
    val = _ByteVal[leadByte]

    if (val < 128) {
        # ASCII: 0xxxxxxx
        return 1
    } else if (val < 192) {
        # Continuation byte or invalid: 10xxxxxx
        # Treat as single byte
        return 1
    } else if (val < 224) {
        # 2-byte sequence: 110xxxxx
        return 2
    } else if (val < 240) {
        # 3-byte sequence: 1110xxxx (includes Japanese)
        return 3
    } else if (val < 248) {
        # 4-byte sequence: 11110xxx
        return 4
    } else {
        # Invalid, treat as single byte
        return 1
    }
}

# Count the number of UTF-8 characters in a string
# Works correctly in POSIX locale where length() returns byte count
function strlen(s,    byteLen, charCount, i, charBytes) {
    byteLen = length(s)
    charCount = 0
    i = 1

    while (i <= byteLen) {
        charBytes = _charByteLen(substr(s, i, 1))
        charCount++
        i += charBytes
    }

    return charCount
}

# Extract a single UTF-8 character at the given character position (1-indexed)
# Returns the character (which may be 1-4 bytes)
function charAt(s, charPos,    byteLen, i, charCount, charBytes) {
    byteLen = length(s)
    charCount = 0
    i = 1

    while (i <= byteLen) {
        charBytes = _charByteLen(substr(s, i, 1))
        charCount++

        if (charCount == charPos) {
            return substr(s, i, charBytes)
        }

        i += charBytes
    }

    return ""
}

# Extract a substring by character positions (1-indexed)
# Similar to substr(s, start, len) but works with UTF-8 characters
function slice(s, start, len,    byteLen, i, charCount, charBytes, result, startByte, endByte) {
    byteLen = length(s)
    charCount = 0
    i = 1
    result = ""
    startByte = 0

    while (i <= byteLen) {
        charBytes = _charByteLen(substr(s, i, 1))
        charCount++

        if (charCount == start) {
            startByte = i
        }

        if (charCount >= start && charCount < start + len) {
            result = result substr(s, i, charBytes)
        }

        if (charCount >= start + len - 1) {
            break
        }

        i += charBytes
    }

    return result
}
