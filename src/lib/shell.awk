@namespace "shell"

function exec(cmd    , ret) {
  while((cmd | getline) > 0) {
    ret = ret $0 "\n"
  }
  close(cmd)
  return ret
}

