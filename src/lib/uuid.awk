@namespace "uuid"

function gen(    ret, cmd) {
  return tolower(shell::exec("uuidgen"))
}
