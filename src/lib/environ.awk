@namespace "environ"

function getOrRaise(name) {
  if (has(name)) {
    return get(name)
  }
  error::raise("ENVIRON[\"" name "\"] is not found")
}


function getOrPanic(name) {
  if (has(name)) {
    return get(name)
  }
  error::panic("ENVIRON[\"" name "\"] is not found")
}

function get(name) {
  return ENVIRON[name]
}

function has(name) {
  return name in ENVIRON
}
