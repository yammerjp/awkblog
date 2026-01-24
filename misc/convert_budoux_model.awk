# BudouX JSON model to AWK converter
# Input: ja.json from BudouX (via stdin)
# Output: AWK code with model data

BEGIN {
    RS = ""
    FS = ""
    print "@namespace \"budoux_model_ja\""
    print ""
    print "function init(model,    totalScore) {"
    print "    totalScore = 0"
    totalScore = 0
}

{
    # Read entire JSON as one record
    json = $0

    # Remove whitespace outside of strings for easier parsing
    gsub(/\n/, "", json)
    gsub(/\r/, "", json)

    # State machine to parse JSON
    len = length(json)
    currentCategory = ""
    inString = 0
    stringStart = 0
    currentKey = ""
    expectValue = 0

    for (i = 1; i <= len; i++) {
        c = substr(json, i, 1)

        if (inString) {
            if (c == "\"" && substr(json, i-1, 1) != "\\") {
                # End of string
                str = substr(json, stringStart, i - stringStart)
                inString = 0

                if (expectValue) {
                    # This shouldn't happen - values are numbers
                } else {
                    currentKey = str
                }
            }
        } else {
            if (c == "\"") {
                # Start of string
                inString = 1
                stringStart = i + 1
            } else if (c == ":") {
                # Check if this is a category key or a value key
                # Look ahead to see if next non-space char is {
                j = i + 1
                while (j <= len && substr(json, j, 1) ~ /[ \t]/) j++
                if (substr(json, j, 1) == "{") {
                    # This is a category
                    currentCategory = currentKey
                } else {
                    # This is a key:value pair, expect number
                    expectValue = 1
                }
            } else if (expectValue && (c ~ /[0-9-]/ || c == "-")) {
                # Start of number
                numStart = i
                while (i <= len && substr(json, i, 1) ~ /[0-9-]/) i++
                i--
                numStr = substr(json, numStart, i - numStart + 1)
                num = int(numStr)

                # Escape the key for AWK string
                escapedKey = currentKey
                gsub(/\\/, "\\\\", escapedKey)
                gsub(/"/, "\\\"", escapedKey)
                gsub(/\n/, "\\n", escapedKey)
                gsub(/\r/, "\\r", escapedKey)
                gsub(/\t/, "\\t", escapedKey)

                # Also escape category
                escapedCategory = currentCategory
                gsub(/\\/, "\\\\", escapedCategory)
                gsub(/"/, "\\\"", escapedCategory)
                gsub(/\n/, "\\n", escapedCategory)
                gsub(/\r/, "\\r", escapedCategory)
                gsub(/\t/, "\\t", escapedCategory)

                printf "    model[\"%s\"][\"%s\"] = %d\n", escapedCategory, escapedKey, num
                totalScore += num

                expectValue = 0
                currentKey = ""
            }
        }
    }
}

END {
    printf "    model[\"_baseScore\"] = %.1f\n", -totalScore * 0.5
    print "}"
}
