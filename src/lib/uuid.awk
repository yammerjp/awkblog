@namespace "lib"

function uuid(    ret) {
  cmd = "uuidgen"
  cmd | getline ret
  close(cmd)
  return ret
}
