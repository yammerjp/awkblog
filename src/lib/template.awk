@namespace "template"

function render(filename, variables, original, alias        , ret, result) {
  RS="{{"
  FS=" "
  while((getline < filename) > 0) {
    if (RS == "{{") {
      # out of {{ }}
      ret = ret $0
      RS = "}}"
    } else {
      switch($1) {
      case "#include":
        # include file
        # {{#include <filename> <alias> is <original>}}
        includeFilename = $2
        aliasItem = $3
        # $4 is "is"
        originalItem = $5
        originalItemExpanded = expandAlias(originalItem, original, alias)

        ret = ret render(includeFilename, variables, originalItemExpanded, aliasItem)
        break;
      case "#include#for":
        # include file with loop
        # {{#include#for <filename> <item> of <items>}}
        includeFilename = $2
        itemName = $3
        # $4 is "of"
        itemsName = $5
        itemsNameExpanded = expandAlias(itemsName, original, alias)

        delete result
        extractVarKeys(result, variables, itemsNameExpanded)
        for (i in result) {
          ret = ret render(includeFilename, variables, itemsNameExpanded "." i, itemName)
        }
        break
      case "##":
        # comment
        # {{## <comment>}}
        break
      default:
        # variable
        # {{<variable>}}
        varName = expandAlias($0, original, alias)
        ret = ret extractVar(variables, varName)
      }
      RS = "{{"
    }
  }
  close(filename)
  return ret
}

function expandAlias(varName, original, alias) {
  if ( index(varName, alias) == 1) {
    return original substr(varName, length(alias) + 1)
  }
  return varName

}

# example:
#   variables["post"]["title"] = "foo"
#
#   extractVar(variables, "post.title")
#     => "foo"
function extractVar(variables, path) {
  idx = index(path, ".")
  if (idx == 0) {
    return variables[path]
  }
  leftone = substr(path, 1, idx - 1)
  others = substr(path, idx + 1)
  return extractVar(variables[leftone], others)
}

# example:
#   variables["posts"]["first"] = "f"
#   variables["posts"]["second"] = "s"
#
#   extractVarKeys(result, variables, "posts")
#     => result[1] = "first", result[2] = "second"
function extractVarKeys(result, variables, path) {
  idx = index(path, ".")
  if (idx == 0) {
    for (i in variables[path]) {
      result[i] = 1
    }
    return
  }
  part = substr(path, 1, idx - 1)
  childParts = substr(path, idx + 1)
  extractVarKeys(result, variables[part], childParts)
}
