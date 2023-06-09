@namespace "template"

function render(filename, variables        , ret) {
  RS="{{"
  while((getline < filename) > 0) {
    if (RS == "{{") {
      ret = ret $0
      RS = "}}"
    } else {
      ret = ret extractVar(variables, $0)
      RS = "{{"
    }
  }
  close(filename)
  return ret
}

function extractVar(variables, dotConnectedVarname) {
  idx = index(dotConnectedVarname, ".")
  if (idx == 0) {
    return variables[dotConnectedVarname]
  }
  return extractVar(variables[substr(dotConnectedVarname, 1, idx - 1)], substr(dotConnectedVarname, idx + 1))
}
