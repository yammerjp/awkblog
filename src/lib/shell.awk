@namespace "shell"

function exec(cmd ,stdinStr    , ret, isFirstLine) {
  isFirstLine = 1
  logger::debug("shell::exec(\"" cmd "\", \"" stdinStr "\")")
  if (stdinStr == "") {
    while((cmd | getline) > 0) {
      if (isFirstLine) {
        isFirstLine = 0
        ret = $0
      } else {
        ret = ret "\n" $0
      }
    }
  } else {
    printf "%s", stdinStr |& cmd
    close(cmd, "to")
    while((cmd |& getline) > 0) {
      if (isFirstLine) {
        isFirstLine = 0
        ret = $0
      } else {
        ret = ret "\n" $0
      }
    }
  }
  if (close(cmd) != 0) {
    error::raise("shell::exec() failed", "shell")
  }
  logger::debug("shell::exec ret: " ret)
  return ret
}

