@namespace "template"

function render(filename, variables, alias, original        , ret, includeFilename, aliasItem, originalItem, originalItemExpanded, itemName, itemsName, itemsNameExpanded, result) {
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
        ret = ret renderInclude(variables, alias, original, $2, $3, $5)
        break;
      case "#include#for":
        # include file with loop
        # {{#include#for <filename> <item> of <items>}}
        ret = ret renderIncludeFor(variables, alias, original, $2, $3, $5)
        break
      case "##":
        # comment
        # {{## <comment>}}
        break
      default:
        # variable
        # {{<variable>}}
        ret = ret renderVariable(variables, alias, original, $0)
      }
      RS = "{{"
    }
  }
  close(filename)
  return ret
}

function renderVariable(variables, alias, original, path        , expandedPath) {
  expandedPath = expandAlias(path, alias, original)
  return extractVar(variables, expandedPath)
}

function renderInclude(variables, alias, original, filename, aliasItem, originalItem      , expandedPath) {
  expandedPath = expandAlias(originalItem, alias, original)
  return render(filename, variables, aliasItem, expandedPath)
}

function renderIncludeFor(variables, alias, original, filename, aliasItem, originalItem        , expandedPath, keys, i, ret) {
  expandedPath = expandAlias(originalItem, alias, original)
  extractVarKeys(keys, variables, expandedPath)
  for (i in keys) {
    ret = ret render(filename, variables, aliasItem, expandedPath "." i)
  }
  return ret
}

# example:
#   expandAlias("p.title", "posts.1", "p")
#     => "posts.1.title"
function expandAlias(varName, alias, original) {
  if (varName == alias) {
    return original
  }
  if ( index(varName, alias ".") == 1) {
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
