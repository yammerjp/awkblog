@namespace "logger"

function debug(message, tag) {
    output("DEBUG", message, tag)
}

function info(message, tag) {
    output("INFO", message, tag)
}

function warning(message, tag) {
    output("WARNING", message, tag)
}

function error(message, tag) {
    output("ERROR", message, tag)
}

function output(level, message, tag) {
    if (!awk::DEBUG && level == "DEBUG") {
        return
    }
    if (tag == "") {
        tag = "default"
    }

    printf "%s %s [%s] %s\n", nowISO8601(), level, tag, message
}

function nowISO8601() {
    return awk::strftime("%Y-%m-%dT%H:%M:%S%z", awk::systime())
}
