@namespace "shell"

function exec(cmd    , ret) {
  logger::debug("shell::exec(\"" cmd "\")")
  while((cmd | getline) > 0) {
    ret = ret $0 "\n"
  }
  close(cmd)
  logger::debug("shell::exec ret: " ret)
  return ret
}

