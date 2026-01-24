@namespace "budoux"

# Internal model array
# Initialized by _init()

function _init() {
    budoux_model_ja::init(_Model)
    utf8::_init()
}

function _getScore(category, key) {
    if ((category in _Model) && (key in _Model[category])) {
        return _Model[category][key]
    }
    return 0
}

# Parse a sentence and split into chunks
# Returns the number of chunks, stores chunks in result array
# Algorithm based on: https://github.com/google/budoux
# Uses UTF-8 character-based processing for POSIX locale compatibility
function parse(sentence, result,
               len, i, score, baseScore,
               chunkCount, currentChar) {

    # Empty string case
    len = utf8::strlen(sentence)
    if (len == 0) {
        return 0
    }

    # First character always starts the first chunk
    chunkCount = 1
    result[1] = utf8::charAt(sentence, 1)

    baseScore = _Model["_baseScore"]

    # Evaluate each position from 2 to len (1-indexed)
    for (i = 2; i <= len; i++) {
        score = baseScore

        # UW1-UW6: unigram features
        if (i > 3) score += _getScore("UW1", utf8::charAt(sentence, i - 3))
        if (i > 2) score += _getScore("UW2", utf8::charAt(sentence, i - 2))
        score += _getScore("UW3", utf8::charAt(sentence, i - 1))
        score += _getScore("UW4", utf8::charAt(sentence, i))
        if (i < len) score += _getScore("UW5", utf8::charAt(sentence, i + 1))
        if (i + 1 < len) score += _getScore("UW6", utf8::charAt(sentence, i + 2))

        # BW1-BW3: bigram features
        if (i > 2) {
            score += _getScore("BW1", utf8::slice(sentence, i - 2, 2))
            score += _getScore("BW2", utf8::slice(sentence, i - 1, 2))
        }
        if (i < len) {
            score += _getScore("BW3", utf8::slice(sentence, i, 2))
        }

        # TW1-TW4: trigram features
        if (i > 3) score += _getScore("TW1", utf8::slice(sentence, i - 3, 3))
        if (i > 2) score += _getScore("TW2", utf8::slice(sentence, i - 2, 3))
        if (i < len) score += _getScore("TW3", utf8::slice(sentence, i - 1, 3))
        if (i + 1 < len) score += _getScore("TW4", utf8::slice(sentence, i, 3))

        # Decision: if score > 0, start a new chunk
        currentChar = utf8::charAt(sentence, i)
        if (score > 0) {
            chunkCount++
            result[chunkCount] = currentChar
        } else {
            result[chunkCount] = result[chunkCount] currentChar
        }
    }

    return chunkCount
}

# Parse and return as a string with separator
function parseToString(sentence, separator,
                       result, count, i, str) {
    count = parse(sentence, result)
    if (count == 0) return ""

    str = result[1]
    for (i = 2; i <= count; i++) {
        str = str separator result[i]
    }
    return str
}
