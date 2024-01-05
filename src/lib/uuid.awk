@namespace "uuid"

function gen(    ret, cmd) {
  cmd = "uuidgen"
  cmd | getline ret
  close(cmd)
  return tolower(ret)
}
