@namespace "uuid"

function gen(    ret) {
  cmd = "uuidgen"
  cmd | getline ret
  close(cmd)
  return ret
}
