@namespace "shell"

function exec(cmd ,stdinStr    , ret) {
  logger::debug("shell::exec(\"" cmd "\", \"" stdinStr "\")")
  if (stdinStr == "") {
    while((cmd | getline) > 0) {
      ret = ret $0 "\n"
    }
  } else {
    print stdinStr |& cmd
    close(cmd, "to")
    while((cmd |& getline) > 0) {
      ret = ret $0 "\n"
    }
  }
  close(cmd)
  logger::debug("shell::exec ret: " ret)
  return ret
}

