@namespace "template"

function render(filename, tree, subTreePath        , ret) {
  if (subTreePath == "") {
    return readFile(filename, tree)
  }

  idx = index(subTreePath, ".")
  if (idx == 0) {
    key = subTreePath
    nextSubtreePath = ""
  } else {
    key = substr(subTreePath, 1, idx - 1)
    nextSubtreePath = substr(subTreePath, idx + 1)
  }

  if (key == "*") {
    for (i in tree) {
      ret = ret render(filename, tree[i], nextSubtreePath)
    }
    return ret
  }
  return render(filename, tree[key], nextSubtreePath)
}

function readFile(filename, tree        , ret) {
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
        # {{#include#for <filename> <subTreePath>}}
        ret = ret render($2, tree, $3)
        break;
      case "#include#for":
        # include file with loop
        # {{#include#if <filename> <loopTreePath>}}
        ret = ret render($2, tree, $3 ".*")
        break
      case "#include#if":
        # include file with if
        # {{#include#if <filename> <boolTreePath> <subTreePath>}}
        if (getVar(tree, $3)) {
          ret = ret render($2, tree)
        }
        break
      case "#include#unless":
        # include file with if
        # {{#include#if <filename> <boolTreePath>}}
        if (!getVar(tree, $3)) {
          ret = ret render($2, tree)
        }
        break
      case "##":
        # comment
        # {{## <comment>}}
        break
      case "#rootvar":
        # root variable of tree
        # {{#rootvar}}
        ret = ret tree
        break
      default:
        # variable
        # {{<variable>}}
        ret = ret getVar(tree, $1)
      }
      RS = "{{"
    }
  }
  close(filename)
  return ret
}

function getVar(tree, path) {
  idx = index(path, ".")
  if (idx == 0) {
    return tree[path]
  }
  key = substr(path, 1, idx - 1)
  nextSubtreePath = substr(path, idx + 1)
  return getVar(tree[key], nextSubtreePath)
}
