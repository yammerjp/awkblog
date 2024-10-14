
# Usage:
#  git ls-files \
#    | grep -e '\.awk$'
#    | xargs -I{} gawk -f misc/variable_convention_validator.awk {}

function find_in_array(target, source,    i) {
    for (i in source) {
        if (target == source[i]) {
            return 1
        }
    }
    return 0
}

# detect function declaration
/^[[:blank:]]*function[[:blank:]]+[a-zA-Z0-9_]+[[:blank:]]*\([a-zA-Z0-9_, \t]*\)/ {
    FuncnameBegin = index($0, "function") + 9
    ParenBegin = index($0, "(")
    ParenEnd = index($0, ")")
    Args = substr($0, ParenBegin + 1, ParenEnd - ParenBegin - 1)

    InFunction = 1
    FunctionName = substr($0, FuncnameBegin, ParenBegin - FuncnameBegin)
    next
}

# detect function end
InFunction && /^}$/ {
    InFunction = 0

    Args = ""
    next
}

InMultiLineString {
    # remove escaped double quote
    gsub(/[^\\]\\"/g, " ")

    # remove string token
    gsub(/"[^"]*"/g, " ")

    if (match($0, "\"")) {
        # finish multi-line string
        InMultiLineString = 0
        gsub(/^[^"]*"/, " ")
    }
}

!InMultiLineString && InFunction {
    gsub("@namespace", " ")

    # remove escaped characters
    gsub(/\\./, " ") 

    StringIsLeftOfRegularExpression = match($0, "\"") < match($0, "/")
    if (StringIsLeftOfRegularExpression) {
        # remove string token
        gsub(/"[^"]*"/, " ")
    }
    
    # remove regular expression
    gsub(/\/[^\/\\]*\[[^\]]*\]/, "/ ")
    gsub(/\/[^\/\\]*\//, " ")

    if (!StringIsLeftOfRegularExpression) {
        # remove string token
        gsub(/"[^"]*"/, " ")
    }


    if (match($0, "\"")) {
        # start multi-line string
        InMultiLineString = 1
        gsub(/"[^"]+$/, " ")
    }

    # remove comment
    gsub(/#.*$/, " ")

    # remove namespace
    gsub(/[a-zA-Z0-9_]*::/, "")

    # remove function call
    gsub(/[a-zA-Z0-9_]*\(/, "")

    # remove operator
    gsub(/[^a-zA-Z0-9_]/, " ")

    for (i = 1; i <= NF; i++) {
        switch ($i) {
            # reserved words
            case "break":
            case "case":
            case "close":
            case "continue":
            case "default":
            case "delete":
            case "else":
            case "exit":
            case "for":
            case "function":
            case "getline":
            case "if":
            case "in":
            case "next":
            case "print":
            case "printf":
            case "return":
            case "switch":
            case "while":
                break

            # not reserved words
            default:
                if (match($i, /^[0-9]+$/)) {
                    # decimal number
                    break
                }
                if (match($i, /^0x[0-9A-Fa-f]+$/)) {
                    # hexadecimal number
                    break
                }
                VariableBeginUpperCase = match($i, /^[A-Z]/)
                VariableIncludesFunctionArguments = match(Args, $i)
                if (VariableBeginUpperCase && VariableIncludesFunctionArguments) {
                    # global variable should be started with upper case
                    print "global variable should start with upper case: \"" $i "\" at " FILENAME ":" NR " in " FunctionName "()"
                }
                if (!VariableBeginUpperCase && !VariableIncludesFunctionArguments) {
                    # local variable should be defined in function arguments
                    print "local variable should be defined in function arguments: \"" $i "\" at " FILENAME ":" NR " in " FunctionName "()"
                }
        }
    }
}
