@namespace "lib"

function render_template(filename, variables        , prebr, ret) {
  prebr = 0
  ret = ""
  while((getline < filename) > 0) {
    if ($0 ~ /^AWKBLOG::[a-z]+$/) {
      varname = substr($0, 10)
      ret = ret sprintf("%s", variables[varname])
      prebr = 0
    } else {
      ret = ret sprintf("%s%s", prebr ? "\n" : "", $0)
      prebr = 1
    }
  }
  if (prebr) {
    ret = ret sprintf("\n")
  }
  close(filename)
  return ret
}
